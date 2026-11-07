# 📡 Panduan Konfigurasi TR-069 pada Modem ONT Pelanggan

Panduan setting TR-069 pada berbagai merk modem ONT agar otomatis terhubung ke server GenieACS dan melaporkan data redaman ke EugineBill.

---

## ⚙️ Data Parameter Utama (Semua Merk)

Gunakan parameter berikut saat mengatur modem apa pun:

* **ACS URL:** `http://acs.euginemediagroup.site:7547/`
* **Periodic Inform:** `Enable` / `Yes`
* **Periodic Inform Interval:** `300` detik (5 menit)
* **Connection Request Username:** `admin`
* **Connection Request Password:** `admin`
* **Connection Request Port:** `7547` (default ONT)

---

## 1. Huawei (HG8145V5 / EG8145V5 / HG8245H5)

1. Buka browser, akses `192.168.100.1` (atau IP gateway ONT).
2. Login menggunakan user admin (misal: `telecomadmin` / `admintelecom`).
3. Masuk ke tab menu **Management** → pilih sub-menu **TR-069**.
4. Isi kolom konfigurasi:
   * **Enable TR-069:** Centang `[x]`
   * **URL:** `http://acs.euginemediagroup.site:7547/`
   * **User Name:** *(Kosongkan)*
   * **Password:** *(Kosongkan)*
   * **Periodic Inform:** Centang `[x] Enable`
   * **Periodic Inform Interval:** `300`
   * **Connection Request Authentication:** Centang `[x]`
   * **Connection Request User Name:** `admin`
   * **Connection Request Password:** `admin`
5. Klik **Apply**.

---

## 2. ZTE (F609 / F670L / F660 / F670)

1. Akses web ONT di `192.168.1.1`.
2. Login admin (misal: `admin` / `admin` atau user superadmin).
3. Masuk ke menu **Administration** → **TR-069** (atau **Network** → **TR-069** tergantung firmware).
4. Atur:
   * **Periodic Inform:** `Enable`
   * **Inform Interval:** `300`
   * **ACS URL:** `http://acs.euginemediagroup.site:7547/`
   * **ACS User / Password:** Kosongkan
   * **Connection Request Auth:** `Enable`
   * **CR Username:** `admin`
   * **CR Password:** `admin`
5. Klik **Submit**.

---

## 3. Fiberhome (AN5506-04-F / HG6821M)

1. Akses web ONT di `192.168.1.1`.
2. Login dengan akun admin Fiberhome.
3. Masuk ke **Management** → **TR-069 Management**.
4. Atur:
   * **ACS URL:** `http://acs.euginemediagroup.site:7547/`
   * **Periodic Inform:** `Enable` (Interval: `300`)
   * **WAN Interface:** Pastikan TR-069 berjalan di interface WAN Internet atau Management.
5. Klik **Apply**.

---

## 4. VSOL / HSGQ (EPON & GPON ONT)

1. Akses web ONT di `192.168.1.1`.
2. Masuk ke menu **Network** → **Remote Management** → **TR-069**.
3. Atur:
   * **ACS URL:** `http://acs.euginemediagroup.site:7547/`
   * **Inform:** `Enable`
   * **Interval:** `300`
4. Klik **Apply / Save**.

---

## 💡 Tips Lapangan (Zero-Touch via OLT Profile)

Jika Anda menggunakan OLT (ZTE C320/C300 atau Huawei MA5608T), Anda bisa membuat **TR-069 Profile** di OLT:
* Setiap kali ada ONT baru yang di-bind / di-otorisasi, OLT akan **otomatis mengirimkan konfigurasi ACS URL ke modem**.
* Teknisi lapangan tidak perlu login ke web modem satu per satu!
