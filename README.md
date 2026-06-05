
<!--
  CRI-HR-Secure – README.md
  Version neutre (contexte académique) et design amélioré.
-->
<div align="center">
  <pre>
 ██████╗██████╗ ██╗      ██╗  ██╗██████╗       ███████╗███████╗ ██████╗██╗   ██╗██████╗ ███████╗
██╔════╝██╔══██╗██║      ██║  ██║██╔══██╗      ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██╔════╝
██║     ██████╔╝██║█████╗███████║██████╔╝█████╗███████╗█████╗  ██║     ██║   ██║██████╔╝█████╗
██║     ██╔══██╗██║╚════╝██╔══██║██╔══██╗╚════╝╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██╔══╝
╚██████╗██║  ██║██║      ██║  ██║██║  ██║      ███████║███████╗╚██████╗╚██████╔╝██║  ██║███████╗
 ╚═════╝╚═╝  ╚═╝╚═╝      ╚═╝  ╚═╝╚═╝  ╚═╝      ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
  </pre>

  <h3>Secure HR Module – ERP Integration</h3>
  <p><i>Internship project – CRI Guelmim-Oued Noun</i></p>

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Odoo-17-blue?logo=odoo" alt="Odoo 17">
    <img src="https://img.shields.io/badge/Docker-24+-blue?logo=docker" alt="Docker">
    <img src="https://img.shields.io/badge/NGINX-Reverse_Proxy-green?logo=nginx" alt="NGINX">
    <img src="https://img.shields.io/badge/HTTPS-Self_Signed-orange" alt="HTTPS">
    <img src="https://img.shields.io/badge/Fail2Ban-1.x-red" alt="Fail2Ban">
    <img src="https://img.shields.io/badge/Auditd-Linux-blue" alt="Auditd">
    <img src="https://img.shields.io/badge/Netdata-Monitoring-brightgreen" alt="Netdata">
    <img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">
  </p>
</div>

---

## 📌 Project Description

**CRI-HR-Secure** is a secure HR module prototype developed during an academic internship at the Regional Investment Centre (CRI) of Guelmim-Oued Noun.  
Due to the constraints of the internship context (no production server access), the solution was designed as an autonomous prototype deployed on a virtual machine simulating an internal corporate network.

Built on **Odoo 17** (containerised with **Docker**) and exposed via an **Nginx reverse proxy** over **HTTPS**, it provides:

- ✅ Employee management (CRUD: name, email, position, department, hire date)  
- ✅ Leave request workflow (annual, sick, unpaid) with HR approval  
- ✅ Role-based access control (RBAC: Administrator, HR Officer, Employee)  
- ✅ Dashboard (employee count, pending requests)  

A **defence-in-depth security architecture** adds the following layers:

| Layer                  | Control                                                          |
|------------------------|------------------------------------------------------------------|
| 🔐 Transport           | HTTPS via Nginx + OpenSSL RSA-4096 (self‑signed certificate)    |
| 📝 Access traceability | Nginx IP access logging                                          |
| 🧑‍⚖️ Authorisation       | Odoo RBAC (3 roles)                                              |
| 🧪 Injection resistance| SQLmap audit – 0 vulnerabilities over 432 tests                  |
| 🛡️ Brute-force defence | Fail2Ban (`odoo-https` jail) – ban after 5 failures in 300s      |
| 🔏 File integrity      | Auditd watch rules on critical config files                      |
| 📊 Observability       | Netdata real‑time monitoring (4,500+ metrics/sec)                |

---

## 🏗️ Architecture

The prototype follows a **three-tier architecture** isolated within a **VirtualBox Host-Only network** (`192.168.56.0/24`):

```
  Windows Workstation (192.168.56.1)
          │
          │ HTTPS (port 443)
          ▼
  ┌───────────────────────────────────────────────┐
  │  Ubuntu 22.04 LTS VM — 192.168.56.101         │
  │  2 vCPU · 2 GB RAM · Host-Only adapter        │
  │                                               │
  │  ┌─────────────────────────────────────────┐  │
  │  │            Docker Engine                │  │
  │  │                                         │  │
  │  │  ┌─────────────┐      ┌─────────────┐   │  │
  │  │  │ Nginx       │ ───► │ Odoo 17     │   │  │
  │  │  │ (Alpine)    │      │ (App)       │   │  │
  │  │  │ port 443    │      │ port 8069   │   │  │
  │  │  └─────────────┘      └──────┬──────┘   │  │
  │  │                               │          │  │
  │  │                               ▼          │  │
  │  │                         ┌─────────────┐   │  │
  │  │                         │ PostgreSQL  │   │  │
  │  │                         │ port 5432   │   │  │
  │  │                         └─────────────┘   │  │
  │  └─────────────────────────────────────────┘  │
  │                                               │
  │  Host services: Nginx · Fail2Ban · Auditd     │
  │                 Netdata (port 19999)          │
  └───────────────────────────────────────────────┘
```

---

## ⚙️ Technology Stack

| Category            | Tool / Version                         | Role                                 |
|---------------------|----------------------------------------|--------------------------------------|
| ERP platform        | Odoo 17 Community                      | HR application layer                 |
| Database            | PostgreSQL 15                          | Persistent data store                |
| Containerisation    | Docker + Compose                       | Service isolation & portability      |
| Reverse proxy       | Nginx (Alpine)                         | TLS termination, IP logging          |
| Virtualisation      | VirtualBox + Ubuntu 22.04 LTS          | Isolated deployment environment      |
| Certificates        | OpenSSL 3.x                            | Self-signed TLS certificate (RSA-4096)|
| Security testing    | SQLmap 1.8                             | SQL‑injection audit                  |
| IPS                 | Fail2Ban 1.x                           | Automated brute‑force mitigation     |
| Audit               | Auditd (Linux Audit)                   | File‑integrity & access logging      |
| Monitoring          | Netdata                                | Real‑time system observability       |

---

## 📋 Prerequisites

- **OS:** Ubuntu 22.04 LTS (VirtualBox VM or physical machine)  
- **RAM:** 4 GB minimum (validated on 4.5 GB)  
- **Docker:** `>=24.x`  
- **Docker Compose:** `>=2.x`  
- **Additional packages:** Nginx, OpenSSL, Fail2Ban, Auditd, Netdata (installation commands provided below)  
- **Network:** VirtualBox Host-Only adapter with static IP `192.168.56.101`

> All deployment steps were validated in a virtualised environment – standard practice for academic prototypes.

---

## 🚀 Quick Start

### 1️⃣ Generate self‑signed TLS certificate
```bash
sudo openssl req -x509 -newkey rsa:4096 \
  -keyout /etc/ssl/private/key.pem \
  -out /etc/ssl/certs/cert.pem \
  -days 365 -nodes \
  -subj "/CN=192.168.56.101"
```

### 2️⃣ Build and load custom Odoo image
```bash
docker build -t cri-odoo-custom:v1 .
docker save cri-odoo-custom:v1 | gzip > cri-odoo-custom.tar.gz

# On the target VM:
docker load -i cri-odoo-custom.tar.gz
```

### 3️⃣ Start containers
```bash
docker compose up -d
```

### 4️⃣ Configure Nginx reverse proxy
```bash
sudo cp configs/nginx-odoo.conf /etc/nginx/sites-available/odoo
sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### 5️⃣ Enable Fail2Ban and Auditd
```bash
sudo cp configs/jail.local /etc/fail2ban/jail.local
sudo cp configs/odoo-https.conf /etc/fail2ban/filter.d/
sudo systemctl restart fail2ban

sudo cp configs/cri.rules /etc/audit/rules.d/
sudo systemctl restart auditd
```

### 6️⃣ Install Netdata
```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

Now access:
- **Odoo:** `https://192.168.56.101`
- **Netdata dashboard:** `http://192.168.56.101:19999`

### 7️⃣ Initial Odoo setup
1. Create database `crihrdb` through the Odoo web interface.  
2. Install **Employees** and **Time Off** modules.  
3. Create three users:
   - `admin` – Administrator  
   - `ahmed_elalami` – HR Officer  
   - `fatima_zahra` – Employee  

---

## 🛡️ Security Controls

### Fail2Ban – Brute‑force policy
| Parameter          | Value                        |
|--------------------|------------------------------|
| Log monitored      | `/var/log/nginx/access.log`  |
| Trigger            | 5 failed `POST /web/login`   |
| Detection window   | 300 seconds                  |
| Ban duration       | 3600 seconds (1 hour)        |
| Mechanism          | Netfilter DROP (iptables)    |

```bash
fail2ban-client status odoo-https
sudo iptables -L f2b-odoo-https -n
```

### Auditd – Watched files
| File                                         | Key             |
|----------------------------------------------|-----------------|
| `/etc/nginx/nginx.conf`                      | `nginx_config`  |
| `/etc/nginx/sites-available/odoo`           | `nginx_config`  |
| `/home/odoo/docker-compose.yml`             | `docker_config` |
| `/home/odoo/Dockerfile`                     | `docker_config` |

Audit records written to `/var/log/audit/audit.log`.

### SQL‑injection audit (SQLmap)
```bash
sqlmap -u "https://192.168.56.101/web/login" --forms --batch
```
**Result:** 432 tests, **0 injectable parameters detected.**

### Brute‑force simulation (Hydra)
```bash
hydra -l admin@example.com -P rockyou-small.txt -s 443 -S 192.168.56.101 \
  https-post-form "/web/login:login=^USER^&password=^PASS^:Invalid"
```
**Expected:** after 5 failures, Fail2Ban bans the attacking IP.

### Performance test (Apache Bench)
```bash
ab -n 100 -c 10 https://192.168.56.101/web/login
```
**Result:** mean response time **0.325 s**, zero failures at concurrency 10.

---

## ✅ Security Validation Results

| Control                     | Mechanism                                   | Result         |
|-----------------------------|---------------------------------------------|----------------|
| Transport encryption        | Nginx + OpenSSL TLS (RSA-4096)              | ✅ Validated   |
| Access traceability         | Nginx IP logging                            | ✅ Validated   |
| Authorisation               | Odoo RBAC (3 roles)                         | ✅ Validated   |
| Injection resistance        | SQLmap – 0 findings                         | ✅ Validated   |
| Brute-force mitigation      | Fail2Ban (`odoo-https` jail)                | ✅ Validated   |
| File integrity audit        | Auditd (write/attr rules)                   | ✅ Validated   |
| Infrastructure monitoring   | Netdata (4,500+ metrics/s)                  | ✅ Validated   |

---

## 📂 Repository Structure

```
CRI-HR-Secure/
├── README.md                    # This file
├── .gitignore
├── docker-compose.yml           # Services: db, odoo
├── Dockerfile                   # Custom image cri-odoo-custom:v1
├── configs/
│   ├── nginx-odoo.conf          # Nginx TLS + reverse proxy
│   ├── jail.local               # Fail2Ban jail definition
│   ├── odoo-https.conf          # Fail2Ban filter regex
│   └── cri.rules                # Auditd watch rules
├── docs/
│   └── RAPPORT_CRI_HR_SECURE.pdf  # Full internship report (PDF)
├── screenshots/                 # Add your screenshots here
│   └── .gitkeep
└── scripts/
    └── setup.sh                 # Automated setup script
```

---

## 📄 Documentation

The complete internship report (PDF, LaTeX typesetting) must be placed at:

```
docs/RAPPORT_CRI_HR_SECURE.pdf
```

It covers:
- Requirements analysis, architecture design, sprint planning
- Full implementation details (Docker, Nginx, HTTPS, RBAC, Fail2Ban, Auditd, Netdata)
- Security validation results and professional discussion

---

## ⚖️ License & Disclaimer

**License:** This project is released under the **MIT License** – free to use, modify, and distribute for academic or professional purposes.

**Disclaimer:**  
This work was carried out as an academic exercise. All data and configurations are for demonstration only. Logos and trademarks belong to their respective owners (CRI Guelmim-Oued Noun, ESTG). Their use here is purely illustrative and does not imply official endorsement.

---

<div align="center">
  <sub>ESTG Guelmim — DUT Réseaux Informatiques et Sécurité (RIS) — Academic Year 2025–2026</sub>
</div>
