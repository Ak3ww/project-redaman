#!/bin/bash
# ==============================================================================
# Project Redaman: Launch GenieACS Instance 2 (Client 2: acs2)
# ==============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}       PROJECT REDAMAN - LAUNCH GENIEACS INSTANCE 2 (CLIENT 2)    ${NC}"
echo -e "${BLUE}==================================================================${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERROR] Mohon jalankan dengan hak akses sudo: sudo bash scripts/setup-client2.sh${NC}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# 1. Prepare directory for client 2 file storage
mkdir -p data/fs-client2
chmod -R 777 data/fs-client2

# 2. Launch Client 2 Containers
echo -e "${YELLOW}Menjalankan kontainer GenieACS untuk Client 2...${NC}"
docker compose up -d genieacs-cwmp-client2 genieacs-nbi-client2 genieacs-fs-client2 genieacs-ui-client2

# 3. Wait for NBI Client 2 (Port 7558)
echo -e "${YELLOW}Menunggu GenieACS NBI Client 2 (Port 7558) siap...${NC}"
NBI_URL="http://localhost:7558"
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
  echo -e "${GREEN}[OK] GenieACS NBI Client 2 berhasil aktif!${NC}"
  
  # Auto-import Virtual Parameters to Instance 2
  echo -e "${YELLOW}Mengimpor Virtual Parameters Redaman ke Instance 2...${NC}"
  bash "$SCRIPT_DIR/import-vps.sh" "$NBI_URL" || true
else
  echo -e "${RED}[WARNING] NBI Client 2 belum merespons. Silakan jalankan 'bash scripts/import-vps.sh http://localhost:7558' nanti.${NC}"
fi

PUBLIC_IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "IP_SERVER_ANDA")

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}      GENIEACS INSTANCE 2 (CLIENT 2) BERHASIL DIAKTIFKAN!        ${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo -e "Detail koneksi untuk Client 2:"
echo -e " - ${YELLOW}GenieACS Web UI${NC}      : http://acs2.euginemediagroup.site:3001"
echo -e " - ${YELLOW}GenieACS NBI (API)${NC}    : http://acs2.euginemediagroup.site:7558"
echo -e " - ${YELLOW}GenieACS CWMP (TR-069)${NC}: http://acs2.euginemediagroup.site:7548"
echo -e ""
echo -e "${BLUE}[PANDUAN SETUP CLIENT 2]:${NC}"
echo -e "1. Buka ${YELLOW}http://acs2.euginemediagroup.site:3001${NC} di browser, lalu klik tombol ${GREEN}ABRACADABRA!${NC}"
echo -e "2. Di EugineBill Client 2 -> Masuk menu Admin -> Settings -> GenieACS:"
echo -e "   - GenieACS URL: ${GREEN}http://acs2.euginemediagroup.site:7558${NC}"
echo -e "   - Klik ${GREEN}Test Connection${NC}"
echo -e "3. Di Modem ONT Pelanggan Client 2:"
echo -e "   - ACS URL: ${GREEN}http://acs2.euginemediagroup.site:7548/${NC}"
echo -e "   - Periodic Inform: Enable (300 detik)"
echo -e "=================================================================="
