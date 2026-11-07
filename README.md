# 📡 Project Redaman: Multi-Instance GenieACS Server for EugineBill

Platform otomasi dan server **GenieACS (TR-069 / CWMP)** multi-tenant untuk integrasi dengan **EugineBill / Salfanet Radius**. Berfungsi untuk mendeteksi redaman optik pelanggan (Optical Rx/Tx Power dalam dBm), monitoring status ONT, dan manajemen jarak jauh (ganti password WiFi & remote reboot).

Server ini dapat menjalankan **2 sistem GenieACS mandiri** dalam 1 server EC2:

| Parameter | Instance 1 (Client 1) | Instance 2 (Client 2) |
| :--- | :--- | :--- |
| **Domain** | `acs.euginemediagroup.site` | `acs2.euginemediagroup.site` |
| **CWMP (Untuk Modem ONT)** | `http://acs.euginemediagroup.site:7547/` | `http://acs2.euginemediagroup.site:7548/` |
| **NBI (Untuk EugineBill)** | `http://acs.euginemediagroup.site:7557` | `http://acs2.euginemediagroup.site:7558` |
| **Web UI Admin** | `http://acs.euginemediagroup.site:3000` | `http://acs2.euginemediagroup.site:3001` |
| **Database MongoDB** | `genieacs` | `genieacs2` |

---

## 📚 Indeks Dokumentasi

1. [🏗️ **Arsitektur Multi-Tenant**](docs/ARCHITECTURE.md) - Rincian port, diagram isolasi database, dan ambang batas redaman.
2. [🔗 **Panduan Integrasi EugineBill**](docs/EUGINEBILL-INTEGRATION.md) - Langkah setting IP di EugineBill, aktivasi kolom redaman, dan ganti password WiFi.
3. [📡 **Panduan Konfigurasi ONT Pelanggan**](docs/ONT-CONFIGURATION.md) - Panduan praktis setting TR-069 untuk berbagai merk modem (Huawei, ZTE, Fiberhome, VSOL/HSGQ).
4. [🛠️ **Panduan Pemecahan Masalah (Troubleshooting)**](docs/TROUBLESHOOTING.md) - Solusi kendala ONT tidak muncul, redaman N/A, dan task pending.

---

## 🚀 Panduan Menjalankan di Server EC2 Ubuntu

Masuk ke server EC2 melalui SSH:
```bash
cd ~/project-redaman
git pull
```

### Menjalankan Instance 1 (Client 1):
```bash
sudo bash scripts/setup-docker.sh
```

### Menjalankan Instance 2 (Client 2):
```bash
sudo bash scripts/setup-client2.sh
```

---

## 🛠️ Perintah Cepat Manajemen Kontainer

```bash
# Cek seluruh kontainer yang aktif (Client 1 & Client 2)
docker compose ps

# Memantau log modem ONT Client 1
docker compose logs -f genieacs-cwmp

# Memantau log modem ONT Client 2
docker compose logs -f genieacs-cwmp-client2

# Restart seluruh layanan
docker compose restart
```

---

## 📜 Lisensi
MIT License. Dibuat untuk ekosistem ISP, RT-RW Net, dan EugineBill.
