# 📡 Project Redaman: GenieACS TR-069 Server for EugineBill

Platform otomasi dan server **GenieACS (TR-069 / CWMP)** terdedikasi untuk integrasi langsung dengan **EugineBill / Salfanet Radius**. Berfungsi untuk mendeteksi redaman optik pelanggan (Optical Rx/Tx Power dalam dBm), monitoring status ONT, dan manajemen jarak jauh (ganti password WiFi & remote reboot).

---

## 🏛️ Arsitektur Sistem

```
+-------------------------------------------------------------------+
|                        RUMAH PELANGGAN                            |
|  ONT / Modem (Huawei / ZTE / Fiberhome / VSOL)                    |
|  ACS URL: http://<IP_SERVER_EC2>:7547/                            |
+---------------------------------+---------------------------------+
                                  |
               TR-069 Inform (CWMP) | Port 7547
                                  v
+-------------------------------------------------------------------+
|                 SERVER AWS EC2 (UBUNTU 24.04 LTS)                 |
|                                                                   |
|   +-------------------+    +----------------------------------+   |
|   |   MongoDB 6.x     |<-->| GenieACS CWMP (Port 7547)         |   |
|   +-------------------+    | GenieACS NBI  (Port 7557 - REST) |   |
|                            | GenieACS FS   (Port 7567)        |   |
|                            | GenieACS UI   (Port 3000)        |   |
|                            +-----------------+----------------+   |
+----------------------------------------------|--------------------+
                                               |
                          NBI REST API Calls   | Port 7557
                                               v
+-------------------------------------------------------------------+
|               EUGINEBILL / SALFANET RADIUS                        |
|  Menu: Admin -> GenieACS -> Devices & Parameters                  |
|  - Deteksi Redaman (RX Power) Otomatis                            |
|  - Edit Nama & Password Wi-Fi (WPA2-PSK)                          |
|  - Remote Reboot & Force Sync                                     |
+-------------------------------------------------------------------+
```

---

## ⚡ Persiapan Port Firewall (AWS Security Group)

Pastikan port berikut telah diizinkan pada **Inbound Rules Security Group** instance EC2 Anda:

| Port | Protokol | Sumber (Source) | Kegunaan |
| :--- | :--- | :--- | :--- |
| **7547** | TCP | `0.0.0.0/0` (Anywhere) | **Wajib:** Komunikasi TR-069 dari ONT pelanggan ke GenieACS CWMP |
| **7557** | TCP | IP Server EugineBill (atau `0.0.0.0/0`) | **Wajib:** Jalur API NBI untuk EugineBill |
| **3000** | TCP | IP Anda (atau `0.0.0.0/0`) | Akses Web UI Admin GenieACS |
| **22** | TCP | IP Anda | Akses SSH remote server |

---

## 🚀 Panduan Instalasi Cepat di Ubuntu 24.04 EC2

Login ke server EC2 Anda melalui SSH, lalu pilih salah satu metode di bawah ini:

### Pilihan 1: Menggunakan Docker Compose (Sangat Direkomendasikan)
Metode ini otomatis memasang Docker, menjalankan container MongoDB & GenieACS, dan mengimpor seluruh Virtual Parameters redaman:

```bash
# 1. Clone repository ini
git clone https://github.com/Ak3ww/project-redaman.git
cd project-redaman

# 2. Jalankan script setup otomatis 1-klik
sudo bash scripts/setup-docker.sh
```

---

### Pilihan 2: Menggunakan Native Systemd (Tanpa Docker)
Jika Anda ingin memasang langsung ke sistem operasi tanpa Docker:

```bash
# 1. Clone repository ini
git clone https://github.com/Ak3ww/project-redaman.git
cd project-redaman

# 2. Jalankan script installer native
sudo bash install-native.sh
```

---

## 🔗 Menghubungkan GenieACS ke EugineBill

Setelah instalasi selesai:
1. Buka dashboard web **EugineBill**.
2. Masuk ke menu **Admin → Settings → GenieACS**.
3. Isi parameter berikut:
   * **GenieACS URL:** `http://<IP_PUBLIC_EC2>:7557` *(Port NBI)*
   * **Username:** *(kosongkan jika tanpa autentikasi NBI)*
   * **Password:** *(kosongkan jika tanpa autentikasi NBI)*
4. Klik tombol **Test Connection**. Jika status berubah hijau/sukses, EugineBill sudah terhubung penuh ke GenieACS!

---

## 📡 Konfigurasi TR-069 pada Modem ONT Pelanggan

Masuk ke panel web ONT pelanggan (biasanya `192.168.1.1` atau `192.168.100.1`):
1. Masuk ke menu **Management → TR-069**.
2. Atur konfigurasi berikut:
   * **ACS URL:** `http://<IP_PUBLIC_EC2>:7547/`
   * **Periodic Inform Enable:** `Enable` / `Yes`
   * **Periodic Inform Interval:** `300` detik (5 menit)
   * **Connection Request Username:** `admin`
   * **Connection Request Password:** `admin`
3. Klik **Apply / Save**.
4. Dalam 1-2 menit, perangkat ONT akan langsung muncul di menu **Admin → GenieACS → Devices** pada EugineBill.

---

## 📊 Virtual Parameters Redaman yang Telah Disertakan

Repository ini sudah mengonfigurasi parser multi-vendor (Huawei, ZTE, Fiberhome, VSOL, HSGQ) di folder `virtual-parameters/`:

* **`RXPower`**: Menangkap redaman optik terima dari ONT dan memformatnya dalam satuan **`dBm`** (contoh: `-21.40 dBm`).
* **`TXPower`**: Menangkap daya pancar optik dari laser ONT (contoh: `2.30 dBm`).
* **`gettemp`**: Suhu modul optik internal (contoh: `48 °C`).
* **`pppoeIP`**: Mendeteksi IP WAN / PPPoE yang didapat ONT.
* **`pppoeUsername`**: Username PPPoE aktif pada koneksi WAN.
* **`getdeviceuptime`**: Uptime perangkat dalam format waktu yang mudah dibaca (`3d 4h 12m`).
* **`getponmode`**: Deteksi mode koneksi PON (`GPON` atau `EPON`).
* **`WlanSSID` & `WlanPassword`**: Nama SSID dan kata sandi WiFi 2.4GHz.

---

## 🛠️ Manajemen Kontainer Docker (Perintah Cepat)

Jika menggunakan opsi Docker:
```bash
# Cek status semua kontainer
docker compose ps

# Melihat log aktif (misal log koneksi ONT ke CWMP)
docker compose logs -f genieacs-cwmp

# Restart semua layanan
docker compose restart

# Mengimpor ulang Virtual Parameter jika ada perubahan script
bash scripts/import-vps.sh
```

---

## 📜 Lisensi
MIT License. Dikembangkan untuk integrasi jaringan FTTH & sistem billing EugineBill.
