#!/usr/bin/env bash
# =============================================================================
# CRI-HR-Secure — Automated Setup Script
# Extracted from the internship report (ESTG Guelmim, 2026)
#
# Run on: Ubuntu 22.04 LTS VM (IP 192.168.56.101)
# Usage:  chmod +x setup.sh && sudo ./setup.sh
# =============================================================================

set -euo pipefail

echo "=== [1/7] Installing system dependencies ==="
sudo apt update
sudo apt install -y nginx openssl fail2ban auditd audispd-plugins curl

echo "=== [2/7] Generating RSA-4096 self-signed TLS certificate ==="
sudo openssl req -x509 -newkey rsa:4096 \
  -keyout /etc/ssl/private/key.pem \
  -out /etc/ssl/certs/cert.pem \
  -days 365 -nodes \
  -subj "/CN=192.168.56.101"

echo "=== [3/7] Configuring Nginx reverse proxy ==="
sudo cp configs/nginx-odoo.conf /etc/nginx/sites-available/odoo
sudo ln -sf /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/odoo
# Disable default site if present
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl reload nginx

echo "=== [4/7] Loading custom Odoo Docker image ==="
# Expects cri-odoo-custom.tar.gz to be present in the current directory.
# Build it on the development machine with:
#   docker build -t cri-odoo-custom:v1 .
#   docker save cri-odoo-custom:v1 | gzip > cri-odoo-custom.tar.gz
if [ -f "cri-odoo-custom.tar.gz" ]; then
  docker load -i cri-odoo-custom.tar.gz
else
  echo "WARNING: cri-odoo-custom.tar.gz not found. Build and transfer it first."
  echo "  docker build -t cri-odoo-custom:v1 ."
  echo "  docker save cri-odoo-custom:v1 | gzip > cri-odoo-custom.tar.gz"
fi

echo "=== [5/7] Starting Docker containers ==="
docker compose up -d

echo "=== [6/7] Configuring Fail2Ban ==="
sudo cp configs/jail.local /etc/fail2ban/jail.local
sudo cp configs/odoo-https.conf /etc/fail2ban/filter.d/odoo-https.conf
sudo fail2ban-client --test   # test configuration
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status odoo-https

echo "=== [7/7] Configuring Auditd ==="
sudo cp configs/cri.rules /etc/audit/rules.d/cri.rules
sudo systemctl enable auditd
sudo systemctl restart auditd
sudo systemctl status auditd --no-pager

echo ""
echo "=========================================================="
echo "  CRI-HR-Secure is up."
echo "  Odoo (HTTPS): https://192.168.56.101"
echo "  Netdata:      http://192.168.56.101:19999"
echo "                (install Netdata separately if needed)"
echo "=========================================================="
echo ""
echo "Next steps:"
echo "  1. Open https://192.168.56.101 and create the database: crihrdb"
echo "  2. Install the 'Employees' and 'Time Off' modules."
echo "  3. Create users: admin, ahmed_elalami (HR Officer), fatima_zahra (Employee)."
