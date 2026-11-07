# 📡 Project Redaman: GenieACS TR-069 Server for EugineBill

Platform otomasi dan server **GenieACS (TR-069 / CWMP)** terdedikasi untuk integrasi langsung dengan **EugineBill / Salfanet Radius**. Berfungsi untuk mendeteksi redaman optik pelanggan (Optical Rx/Tx Power dalam dBm), monitoring status ONT, dan manajemen jarak jauh (ganti password WiFi & remote reboot).

* **Domain Server:** `acs.euginemediagroup.site`
* **IP Server (AWS EC2):** `16.176.198.126`

---

## 📚 Indeks Dokumentasi Lengkap

Untuk kemudahan operasional dan konfigurasi, silakan baca dokumen pendukung di folder `docs/`:

1. [🏗️ **Arsitektur Sistem & Alur Data**](docs/ARCHITECTURE.md) - Rincian port, alur data ONT ke GenieACS & EugineBill, dan standar ambang batas redaman (*threshold* dBm).
2. [🔗 **Panduan Integrasi EugineBill**](docs/EUGINEBILL-INTEGRATION.md) - Langkah setting IP di EugineBill, konfigurasi kolom redaman di tabel perangkat, dan fitur ganti password WiFi.
3. [📡 **Panduan Konfigurasi ONT Pelanggan**](docs/ONT-CONFIGURATION.md) - Panduan praktis setting TR-069 untuk berbagai merk modem (Huawei, ZTE, Fiberhome, VSOL/HSGQ).
4. [🛠️ **Panduan Pemecahan Masalah (Troubleshooting)**](docs/TROUBLESHOOTING.md) - Solusi kendala ONT tidak muncul, redaman N/A, status task pending, dan firewall.

---

## ⚡ Rincian Endpoint Layanan

| Layanan | URL Endpoint | Kegunaan |
| :--- | :--- | :--- |
| **GenieACS CWMP (TR-069)** | `http://acs.euginemediagroup.site:7547/` | Diisi di menu TR-069 pada modem ONT pelanggan |
| **GenieACS NBI (REST API)** | `http://acs.euginemediagroup.site:7557` | Diisi di EugineBill (`Admin -> Settings -> GenieACS`) |
| **GenieACS Web UI** | `http://acs.euginemediagroup.site:3000` | Panel kontrol admin standalone (user: `admin` / `admin`) |
| **GenieACS File Server** | `http://acs.euginemediagroup.site:7567` | Penyimpanan firmware dan file konfigurasi |

---

## 🚀 Perintah Cepat di Server EC2 Ubuntu

```bash
# Masuk ke folder project
cd ~/project-redaman

# Cek status seluruh kontainer
docker compose ps

# Memantau log koneksi modem ONT (real-time)
docker compose logs -f genieacs-cwmp

# Mengimpor ulang Virtual Parameter redaman jika diubah
bash scripts/import-vps.sh

# Restart seluruh layanan
docker compose restart
```

---

## 📜 Lisensi
MIT License. Dibuat untuk ekosistem ISP, RT-RW Net, dan EugineBill.
