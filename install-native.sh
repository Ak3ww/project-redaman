#!/bin/bash
# ==============================================================================
# Project Redaman: Native Systemd Installer for Ubuntu 24.04 LTS (Noble)
# ==============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERROR] Mohon jalankan sebagai root / sudo: sudo bash install-native.sh${NC}"
  exit 1
fi

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}     INSTALLING GENIEACS NATIVE (SYSTEMD) PADA UBUNTU 24.04       ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# 1. Update and install prerequisites
echo -e "${YELLOW}[1/6] Memasang paket dependensi (curl, gnupg)...${NC}"
apt-get update
apt-get install -y curl gnupg build-essential

# 2. Install MongoDB 7.0 for Ubuntu 24.04
echo -e "${YELLOW}[2/6] Memasang MongoDB 7.0 Community Edition...${NC}"
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
  gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor --yes

# Noble 24.04 repo
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
  tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update
apt-get install -y mongodb-org
systemctl daemon-reload
systemctl enable --now mongod

# 3. Install Node.js 20 LTS
echo -e "${YELLOW}[3/6] Memasang Node.js 20 LTS...${NC}"
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

# 4. Install GenieACS globally
echo -e "${YELLOW}[4/6] Memasang GenieACS v1.2 via NPM...${NC}"
npm install -g --unsafe-perm genieacs@1.2.13

# Create dirs and config
mkdir -p /opt/genieacs /var/log/genieacs /var/lib/genieacs
cat << 'EOF' > /opt/genieacs/config.json
{
  "MONGODB_CONNECTION_URL": "mongodb://127.0.0.1:27017/genieacs",
  "CWMP_INTERFACE": "0.0.0.0",
  "CWMP_PORT": 7547,
  "CWMP_SSL": false,
  "NBI_INTERFACE": "0.0.0.0",
  "NBI_PORT": 7557,
  "FS_INTERFACE": "0.0.0.0",
  "FS_PORT": 7567,
  "UI_INTERFACE": "0.0.0.0",
  "UI_PORT": 3000,
  "LOG_LEVEL": "info"
}
EOF

# 5. Create Systemd Services
echo -e "${YELLOW}[5/6] Membuat file Systemd services untuk GenieACS...${NC}"

# CWMP
cat << 'EOF' > /etc/systemd/system/genieacs-cwmp.service
[Unit]
Description=GenieACS CWMP (TR-069)
After=network.target mongod.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/genieacs-cwmp --config /opt/genieacs/config.json
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# NBI
cat << 'EOF' > /etc/systemd/system/genieacs-nbi.service
[Unit]
Description=GenieACS NBI (REST API)
After=network.target mongod.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/genieacs-nbi --config /opt/genieacs/config.json
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# FS
cat << 'EOF' > /etc/systemd/system/genieacs-fs.service
[Unit]
Description=GenieACS FS (File Server)
After=network.target mongod.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/genieacs-fs --config /opt/genieacs/config.json
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# UI
cat << 'EOF' > /etc/systemd/system/genieacs-ui.service
[Unit]
Description=GenieACS Admin Web UI
After=network.target mongod.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/genieacs-ui --config /opt/genieacs/config.json
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Fix binary path if installed in /usr/local/bin
if [ -f /usr/local/bin/genieacs-cwmp ]; then
  sed -i 's|/usr/bin/genieacs|/usr/local/bin/genieacs|g' /etc/systemd/system/genieacs-*.service
fi

# 6. Enable and Start Services
echo -e "${YELLOW}[6/6] Menjalankan layanan GenieACS...${NC}"
systemctl daemon-reload
systemctl enable --now genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui

# Import Virtual Parameters
sleep 3
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/scripts/import-vps.sh" "http://localhost:7557" || true

PUBLIC_IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "IP_SERVER_ANDA")
echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}    INSTALASI NATIVE SELESAI & GENIEACS SYSTEMD AKTIF!            ${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo -e "GenieACS Web UI: http://${PUBLIC_IP}:3000"
echo -e "GenieACS NBI API: http://${PUBLIC_IP}:7557"
echo -e "GenieACS CWMP: http://${PUBLIC_IP}:7547"
