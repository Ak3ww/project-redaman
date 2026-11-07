# 🏗️ Arsitektur Sistem & Spesifikasi Teknis

Dokumen ini menjelaskan alur kerja, port jaringan, dan integrasi data antara modem pelanggan (ONT), server GenieACS (EC2), dan sistem billing EugineBill.

---

## 1. Diagram Alur Data

```
[Rumah Pelanggan]
  ONT (Huawei/ZTE/dll)
       │
       │ TR-069 Inform (Periodic 300s)
       │ HTTP GET/POST via Port 7547
       ▼
[Cloudflare DNS Only: acs.euginemediagroup.site]
       │
       │ (Bypass proxy / Direct ke IP Server)
       ▼
[AWS EC2 Ubuntu 24.04: 16.176.198.126]
  ┌─────────────────────────────────────────────────────────┐
  │ Docker Stack                                            │
  │                                                         │
  │  genieacs-cwmp (Port 7547)                              │
  │    │ (Menerima parameter optik, serial number, pppoe)   │
  │    ▼                                                    │
  │  MongoDB (Port 27017 internal)                          │
  │    ▲                                                    │
  │    │                                                    │
  │  genieacs-nbi (Port 7557)                               │
  │    │ (REST API untuk query device & task)               │
  │  genieacs-ui  (Port 3000)                               │
  │    │ (Web UI Admin standalone)                          │
  │  genieacs-fs  (Port 7567)                               │
  │    │ (File server storage)                              │
  └────┼────────────────────────────────────────────────────┘
       │
       │ REST API JSON via Port 7557
       ▼
[EugineBill / Salfanet Radius]
  - Admin Menu: Devices, Tasks, Virtual Parameters
  - Deteksi Redaman (Rx Optical Power dalam dBm)
  - Fitur Ganti Password Wi-Fi Pelanggan (WPA2-PSK)
  - Remote Reboot ONT
```

---

## 2. Rincian Port Jaringan & Akses

| Komponen | Port | Protokol | Endpoint Publik | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| **CWMP Service** | `7547` | TCP / HTTP | `http://acs.euginemediagroup.site:7547/` | Jalur utama komunikasi ONT client ke ACS |
| **NBI REST API** | `7557` | TCP / HTTP | `http://acs.euginemediagroup.site:7557` | Jalur API untuk ditarik oleh EugineBill |
| **Admin Web UI** | `3000` | TCP / HTTP | `http://acs.euginemediagroup.site:3000` | Panel kontrol visual GenieACS |
| **File Server (FS)** | `7567` | TCP / HTTP | `http://acs.euginemediagroup.site:7567` | Penyimpanan file konfigurasi/firmware |
| **MongoDB** | `27017` | TCP | *Internal Docker Only* | Database penyimpanan state dan task |

---

## 3. Mekanisme Deteksi Redaman (Virtual Parameters)

TR-069 setiap vendor modem menyimpan data redaman (*optical power*) di path parameter yang berbeda. Sistem ini menggunakan **Virtual Parameters** di GenieACS yang otomatis membaca path yang sesuai dan menstandardisasi hasilnya menjadi format **dBm**:

| Vendor ONT | Path Parameter TR-069 Bawaan | Nama Virtual Parameter | Format Output |
| :--- | :--- | :--- | :--- |
| **Huawei** (HG8145V5, EG8145V5) | `InternetGatewayDevice.WANDevice.*.X_GponInterafceConfig.RXPower` | `RXPower` | `-21.45 dBm` |
| **ZTE** (F609, F670, F660) | `InternetGatewayDevice.WANDevice.*.WANGponInterfaceConfig.RXPower` atau `WANEpon...` | `RXPower` | `-19.80 dBm` |
| **Fiberhome** (AN5506) | `InternetGatewayDevice.WANDevice.*.X_FH_OpticalInfo.RxPower` | `RXPower` | `-22.10 dBm` |
| **VSOL / HSGQ** | `Device.Optical.Interface.*.RxPower` | `RXPower` | `-20.50 dBm` |

---

## 4. Standar Ambang Batas Redaman (Threshold)

Sistem mengacu pada standar kualitas optik FTTH GPON/EPON berikut:
* 🟢 **Optimal:** `-15.00 dBm` s/d `-23.99 dBm` (Sangat baik, internet stabil)
* 🟡 **Waspada (Warning):** `-24.00 dBm` s/d `-26.99 dBm` (Mendekati batas toleransi)
* 🔴 **Kritis (Drop / High Loss):** `≤ -27.00 dBm` (Potensi paket loss / disko)
* ⚫ **LOS / Offline:** Tidak ada sinyal cahaya / kabel putus / modem mati
