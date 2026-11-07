#!/bin/bash
# ==============================================================================
# Project Redaman: Automated GenieACS Docker Setup for Ubuntu 24.04 LTS
# ==============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}       PROJECT REDAMAN - GENIEACS DOCKER AUTOMATION               ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# 1. Check Root / Sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERROR] Mohon jalankan script ini dengan hak akses sudo: sudo bash scripts/setup-docker.sh${NC}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# 2. Check and Install Docker
if ! command -v docker >/dev/null 2>&1; then
  echo -e "${YELLOW}[1/4] Docker belum terpasang. Mengunduh dan memasang Docker CE resmi...${NC}"
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
  echo -e "${GREEN}[OK] Docker berhasil dipasang!${NC}"
else
  echo -e "${GREEN}[1/4] Docker sudah terpasang: $(docker --version)${NC}"
fi

# Ensure docker compose plugin exists
if ! docker compose version >/dev/null 2>&1; then
  echo -e "${YELLOW}Memasang docker-compose-plugin...${NC}"
  apt-get update && apt-get install -y docker-compose-plugin
fi

# 3. Prepare Directories
echo -e "${YELLOW}[2/4] Menyiapkan direktori database dan log...${NC}"
mkdir -p data/mongo data/fs data/log
chmod -R 777 data/

# 4. Build and Start Containers
echo -e "${YELLOW}[3/4] Membangun dan menjalankan stack GenieACS Docker...${NC}"
docker compose down || true
docker compose up -d --build

# 5. Wait for GenieACS NBI to be ready
echo -e "${YELLOW}[4/4] Menunggu layanan GenieACS NBI siap...${NC}"
NBI_URL="http://localhost:7557"
READY=0
for i in {1..30}; do
  if curl -s -f "$NBI_URL/devices" >/dev/null 2>&1; then
    READY=1
    break
  fi
  echo -n "."
  sleep 2
done
echo ""

if [ $READY -eq 1 ]; then
  echo -e "${GREEN}[OK] GenieACS NBI berhasil aktif!${NC}"
  
  # Auto-import Virtual Parameters
  echo -e "${YELLOW}Mengimpor Virtual Parameters untuk kalkulasi Redaman Multi-Vendor...${NC}"
  bash "$SCRIPT_DIR/import-vps.sh" "$NBI_URL" || true
else
  echo -e "${RED}[WARNING] GenieACS NBI membutuhkan waktu lebih lama untuk start. Silakan jalankan 'bash scripts/import-vps.sh' nanti.${NC}"
fi

# 6. Display IP & Integration Information
PUBLIC_IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "IP_SERVER_ANDA")

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}      INSTALASI GENIEACS PROJECT REDAMAN BERHASIL!               ${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo -e "Berikut rincian koneksi ke server ini:"
echo -e " - ${YELLOW}GenieACS Web UI${NC}      : http://${PUBLIC_IP}:3000"
echo -e " - ${YELLOW}GenieACS NBI (API)${NC}    : http://${PUBLIC_IP}:7557"
echo -e " - ${YELLOW}GenieACS CWMP (TR-069)${NC}: http://${PUBLIC_IP}:7547"
echo -e ""
echo -e "${BLUE}[LANGKAH PENTING SELANJUTNYA]:${NC}"
echo -e "1. ${YELLOW}Buka Port AWS Security Group:${NC}"
echo -e "   - Port 7547 (TCP) -> Untuk modem ONT lapor redaman ke CWMP"
echo -e "   - Port 7557 (TCP) -> Untuk API EugineBill"
echo -e "   - Port 3000 (TCP) -> Untuk buka UI GenieACS di browser"
echo -e ""
echo -e "2. ${YELLOW}Hubungkan ke EugineBill:${NC}"
echo -e "   - Buka EugineBill -> Masuk menu Admin -> Settings -> GenieACS"
echo -e "   - Masukkan GenieACS URL: ${GREEN}http://${PUBLIC_IP}:7557${NC}"
echo -e "   - Klik ${GREEN}Test Connection${NC}"
echo -e ""
echo -e "3. ${YELLOW}Setting di Modem ONT Pelanggan:${NC}"
echo -e "   - Masuk menu Management -> TR-069"
echo -e "   - ACS URL: ${GREEN}http://${PUBLIC_IP}:7547/${NC}"
echo -e "   - Periodic Inform: Enable (300 seconds)"
echo -e "=================================================================="
