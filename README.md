# CRI-HR-Secure

```
 ██████╗██████╗ ██╗      ██╗  ██╗██████╗       ███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗
██╔════╝██╔══██╗██║      ██║  ██║██╔══██╗      ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝
██║     ██████╔╝██║█████╗███████║██████╔╝█████╗███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗
██║     ██╔══██╗██║╚════╝██╔══██║██╔══██╗╚════╝╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝
╚██████╗██║  ██║██║      ██║  ██║██║  ██║      ███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗
 ╚═════╝╚═╝  ╚═╝╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝      ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

**Secure Design and Deployment of an HR Module Integrated into an ERP System**
*The Case of CRI Guelmim-Oued Noun*

---

> **Student:** Abderrahmane Aroussi — ESTG Guelmim, DUT Réseaux Informatiques et Sécurité (RIS)
> **Academic Supervisor:** Pr. Tarek Ait Baha
> **Professional Supervisors:** Mr. A. Ouboussekssou (IT Manager) · Ms. S. Boukha (HR Manager)
> **Internship Period:** April – June 2026

---

## Table of Contents

- [Project Description](#project-description)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Security Controls](#security-controls)
- [Security Validation Results](#security-validation-results)
- [Screenshots](#screenshots)
- [Repository Structure](#repository-structure)
- [Documentation](#documentation)
- [License](#license)

---

## Project Description

The **CRI-HR-Secure** prototype addresses the absence of a digital HR solution at the Regional
Investment Centre (CRI) of Guelmim-Oued Noun. In the absence of dedicated IT infrastructure,
an autonomous prototype was designed and deployed on a virtual machine simulating an internal
network, based on **Odoo 17** containerised with **Docker** and exposed via an **Nginx reverse proxy**
over **HTTPS**.

The prototype delivers core HR functions:

- Employee management (CRUD: name, email, position, department, hire date)
- Leave request workflow (annual, sick, unpaid)
- Leave approval by HR Officer
- Role-based authentication and access control (RBAC: Admin, HR Officer, Employee)
- Dashboard (employee count, pending requests)

A **defence-in-depth security architecture** was built on top of the application, combining:

| Layer | Control |
|---|---|
| Transport | HTTPS via Nginx + OpenSSL RSA-4096 self-signed certificate |
| Access traceability | Nginx IP access logging |
| Authorisation | Odoo RBAC (3 roles) |
| Injection resistance | SQLmap audit — 0 findings over 432 tests |
| Brute-force mitigation | Fail2Ban (`odoo-https` jail) |
| File integrity | Auditd watch rules on critical config files |
| Observability | Netdata real-time system monitoring (4,500+ metrics/s) |

---

## Architecture

The prototype follows a **three-tier architecture** deployed entirely within a **VirtualBox Host-Only
network** (`192.168.56.0/24`), isolating it from external internet access:

```
  Windows Workstation (192.168.56.1)
          |
          | HTTPS (port 443)
          |
  ┌───────▼──────────────────────────────────────┐
  │  Ubuntu 22.04 LTS VM — 192.168.56.101        │
  │  2 vCPU · 2 GB RAM · Host-Only adapter       │
  │                                              │
  │  ┌─────────────────────────────────────────┐ │
  │  │           Docker Engine                 │ │
  │  │                                         │ │
  │  │  ┌──────────────────────┐               │ │
  │  │  │  Nginx (Alpine)      │               │ │
  │  │  │  Port 443 (HTTPS)    │               │ │
  │  │  │  Reverse Proxy       │               │ │
  │  │  └──────────┬───────────┘               │ │
  │  │             │ proxy_pass → localhost:8069│ │
  │  │  ┌──────────▼───────────┐               │ │
  │  │  │  Odoo 17             │               │ │
  │  │  │  Port 8069 (internal)│               │ │
  │  │  │  Application Server  │               │ │
  │  │  └──────────┬───────────┘               │ │
  │  │             │ SQL (internal Docker net)  │ │
  │  │  ┌──────────▼───────────┐               │ │
  │  │  │  PostgreSQL 15       │               │ │
  │  │  │  Port 5432 (internal)│               │ │
  │  │  │  Database: cri_hr_db │               │ │
  │  │  └──────────────────────┘               │ │
  │  └─────────────────────────────────────────┘ │
  │                                              │
  │  Host services: Nginx · Fail2Ban · Auditd    │
  │                 Netdata (:19999)             │
  └──────────────────────────────────────────────┘
```

**Network:** VirtualBox Host-Only (`192.168.56.0/24`) — completely isolated from the internet.

---

## Technology Stack

| Category | Tool / Version | Role |
|---|---|---|
| ERP platform | Odoo 17 Community | HR application layer |
| Database | PostgreSQL 15 | Persistent data store |
| Containerisation | Docker + Compose | Service isolation and portability |
| Reverse proxy | Nginx (Alpine) | TLS termination, IP logging |
| Virtualisation | VirtualBox + Ubuntu 22.04 LTS | Isolated deployment environment |
| Certificates | OpenSSL 3.x | Self-signed TLS certificate (RSA-4096) |
| Security testing | SQLmap 1.8 | SQL-injection audit |
| IPS | Fail2Ban 1.x | Automated brute-force mitigation |
| Audit | Auditd (Linux Audit) | File-integrity and access logging |
| Monitoring | Netdata | Real-time system observability |

---

## Prerequisites

Before deploying this prototype, ensure the following are available on the **host machine**:

- **OS:** Ubuntu 22.04 LTS (on a VirtualBox VM, or bare metal)
- **RAM:** minimum 4 GB recommended (prototype validated on 4.5 GB)
- **Docker:** `>=24.x`
- **Docker Compose:** `>=2.x`
- **Nginx:** installed on the VM host (`sudo apt install nginx`)
- **OpenSSL:** `3.x` (`sudo apt install openssl`)
- **Fail2Ban:** (`sudo apt install fail2ban`)
- **Auditd:** (`sudo apt install auditd audispd-plugins`)
- **Netdata:** (install via official script — see Quick Start)
- **Network:** VirtualBox Host-Only adapter configured on `192.168.56.0/24`, static IP `192.168.56.101`

---

## Quick Start

### 1. Generate the Self-Signed TLS Certificate

```bash
sudo openssl req -x509 -newkey rsa:4096 \
  -keyout /etc/ssl/private/key.pem \
  -out /etc/ssl/certs/cert.pem \
  -days 365 -nodes \
  -subj "/CN=192.168.56.101"
```

### 2. Build and Transfer the Custom Odoo Image

> **Note:** `cri-odoo-custom.tar.gz` is not included in this repository.
> Build it from the `Dockerfile` provided:

```bash
# On the development machine:
docker build -t cri-odoo-custom:v1 .
docker save cri-odoo-custom:v1 | gzip > cri-odoo-custom.tar.gz

# Transfer the archive to the VM, then on the VM:
docker load -i cri-odoo-custom.tar.gz
```

### 3. Start the Containers

```bash
docker compose up -d
```

Odoo will be available internally on `http://localhost:8069`.

### 4. Configure Nginx as Reverse Proxy

```bash
sudo cp configs/nginx-odoo.conf /etc/nginx/sites-available/odoo
sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/odoo
sudo nginx -t && sudo systemctl reload nginx
```

Odoo is now accessible at `https://192.168.56.101`.

### 5. Configure and Enable Fail2Ban

```bash
sudo cp configs/jail.local /etc/fail2ban/jail.local
sudo cp configs/odoo-https.conf /etc/fail2ban/filter.d/odoo-https.conf
sudo systemctl restart fail2ban
sudo fail2ban-client status odoo-https   # verify jail is active
```

### 6. Configure and Enable Auditd

```bash
sudo cp configs/cri.rules /etc/audit/rules.d/cri.rules
sudo systemctl restart auditd
sudo systemctl status auditd             # verify service is active (running)
```

### 7. Install and Start Netdata

```bash
# Install via official script (requires internet access during setup):
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
# Dashboard accessible at:
# http://192.168.56.101:19999
```

### 8. Initial Odoo Setup

1. Open `https://192.168.56.101` in a browser on the Windows host.
2. Create the database `crihrdb` through the Odoo web interface.
3. Install the **Employees** and **Time Off** modules.
4. Create the three user accounts:
   - `admin` — Administrator role
   - `ahmed_elalami` — HR Officer role
   - `fatima_zahra` — Employee role

---

## Security Controls

### Fail2Ban — Brute-Force Policy

Jail `odoo-https` enforces:

| Parameter | Value |
|---|---|
| Monitored log | `/var/log/nginx/access.log` |
| Trigger | 5 failed `POST /web/login` attempts |
| Detection window | 300 seconds |
| Ban duration | 3600 seconds (1 hour) |
| Mechanism | Netfilter DROP rule via iptables |

Verify ban status:

```bash
fail2ban-client status odoo-https
sudo iptables -L f2b-odoo-https -n
```

### Auditd — Monitored Files

Write and attribute-change events are audited on:

| File | Key |
|---|---|
| `/etc/nginx/nginx.conf` | `nginx_config` |
| `/etc/nginx/sites-available/odoo` | `nginx_config` |
| `/home/odoo/docker-compose.yml` | `docker_config` |
| `/home/odoo/Dockerfile` | `docker_config` |

Audit records are written to `/var/log/audit/audit.log`.

### SQL-Injection Audit

```bash
# Run from the attacker/test machine (SQLmap must be installed):
sqlmap -u "https://192.168.56.101/web/login" --forms --batch
```

Result from validation: **432 tests, 0 injectable parameters detected.**

### Brute-Force Simulation (Validation)

```bash
hydra -l admin@example.com \
      -P /usr/share/wordlists/rockyou-small.txt \
      -s 443 -S \
      192.168.56.101 \
      https-post-form "/web/login:login=^USER^&password=^PASS^:Invalid"
```

Expected outcome: after 5 failed attempts, Fail2Ban bans the attacker IP automatically.

### Performance (Apache Bench)

```bash
ab -n 100 -c 10 https://192.168.56.101/web/login
```

Validated result: mean response time **0.325 s**, zero failures at concurrency 10.

---

## Security Validation Results

| Control | Mechanism | Result |
|---|---|---|
| Transport encryption | Nginx + OpenSSL TLS (RSA-4096) | ✅ Validated |
| Access traceability | Nginx IP logging | ✅ Validated |
| Authorisation | Odoo RBAC (3 roles) | ✅ Validated |
| Injection resistance | SQLmap — 0 findings | ✅ Validated |
| Brute-force mitigation | Fail2Ban (`odoo-https` jail) | ✅ Validated |
| File integrity audit | Auditd (write/attr rules) | ✅ Validated |
| Infrastructure monitoring | Netdata (4,500+ metrics/s) | ✅ Validated |

---

## Screenshots

Screenshots from the validated prototype are stored in `screenshots/`.
Add your own captures or extract them from the full PDF report in `docs/`.

Suggested captures:
- Odoo login page with HTTPS confirmed in browser address bar
- HR module employee list (RBAC-controlled columns)
- VirtualBox Host-Only adapter configuration
- Nginx access log with client IP
- SQLmap execution output (432 tests, 0 findings)
- Fail2Ban service status + `odoo-https` jail active
- Auditd service status + watch rules loaded
- Netdata dashboard (CPU, RAM, network metrics)
- Netdata traffic spike during brute-force simulation
- iptables DROP rule confirmation after Fail2Ban ban

---

## Repository Structure

```
CRI-HR-Secure/
├── README.md                   ← This file
├── .gitignore
├── docker-compose.yml          ← All services (db, odoo)
├── Dockerfile                  ← Custom Odoo image (cri-odoo-custom:v1)
├── configs/
│   ├── nginx-odoo.conf         ← Nginx reverse-proxy + TLS config
│   ├── jail.local              ← Fail2Ban jail definition (odoo-https)
│   ├── odoo-https.conf         ← Fail2Ban filter (POST /web/login regex)
│   └── cri.rules               ← Auditd watch rules
├── docs/
│   └── RAPPORT_CRI_HR_SECURE.pdf   ← Add the full PDF report here
├── screenshots/
│   └── .gitkeep
└── scripts/
    └── setup.sh                ← Automated setup script
```

---

## Documentation

The full internship report (PDF, LaTeX typesetting) must be placed at:

```
docs/RAPPORT_CRI_HR_SECURE.pdf
```

It is not included in this repository for size reasons. The report covers:
requirements analysis, architecture design, sprint planning, full implementation details,
security validation, results analysis, and professional discussion.

---

## License

This project is released under the **MIT License**.
You are free to use, modify, and distribute it for academic or professional purposes.

---

*ESTG Guelmim — DUT Réseaux Informatiques et Sécurité (RIS) — Academic Year 2025–2026*
