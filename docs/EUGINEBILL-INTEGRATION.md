# 🔗 Panduan Integrasi GenieACS dengan EugineBill

Dokumen ini menjelaskan langkah demi langkah untuk menyambungkan server GenieACS ke **EugineBill / Salfanet Radius** agar seluruh modem pelanggan dan nilai redaman otomatis muncul di panel billing.

---

## 1. Konfigurasi Koneksi di EugineBill

1. Login ke panel **EugineBill** sebagai Administrator.
2. Buka menu: **Admin → Settings → GenieACS**.
3. Masukkan parameter koneksi:
   * **GenieACS URL:** `http://acs.euginemediagroup.site:7557`
   * **Username:** *(Kosongkan)*
   * **Password:** *(Kosongkan)*
4. Klik tombol **Test Connection**.
5. **Indikator Sukses:**
   * Muncul notifikasi hijau: *"Connection successful"*.
   * Versi GenieACS dan jumlah perangkat terdeteksi.

---

## 2. Menampilkan Redaman di Tabel Perangkat (`DEVICE_LIST`)

Agar nilai redaman (RX Power) langsung terlihat di kolom tabel daftar perangkat pelanggan:
1. Buka menu **Admin → GenieACS → Parameter Config**.
2. Pilih tab **DEVICE_LIST**.
3. Pastikan parameter **RX Power** aktif:
   * **Label:** `RX Power`
   * **Parameter Path:** `VirtualParameters.RXPower`
   * **Enabled:** `Yes / Centang`
   * **Display Order:** Posisikan di urutan awal (misal urutan 2 atau 3 di samping Nama/Serial Number).
4. Klik **Save**.
5. Buka menu **Admin → GenieACS → Devices**, kolom **RX Power** sekarang menampilkan nilai redaman real-time (contoh: `-22.50 dBm`).

---

## 3. Fitur Ganti Password Wi-Fi Pelanggan (1-Klik)

Teknisi atau CS dapat mengubah nama Wi-Fi (SSID) dan Password pelanggan langsung dari EugineBill:
1. Buka menu **Admin → GenieACS → Devices**.
2. Klik tombol **Edit WiFi** pada perangkat target.
3. Form akan menampilkan konfigurasi WLAN aktif:
   * **SSID:** Nama Wi-Fi baru.
   * **Security Mode:** Pilih `WPA2-PSK` (rekomendasi).
   * **Password:** Kata sandi baru (minimal 8 karakter).
   * **Enable:** Aktif / Non-aktifkan radio Wi-Fi.
4. Klik **Update WiFi**.
5. **Mekanisme yang Berjalan di Balik Layar:**
   * EugineBill mengirim task `setParameterValues` ke GenieACS NBI.
   * GenieACS mengirim *Connection Request* ke modem ONT.
   * Modem ONT menerapkan SSID & kata sandi baru dalam 2–5 detik tanpa perlu teknisi datang ke rumah pelanggan.

---

## 4. Fitur Remote Reboot & Force Sync

* **Reboot:** Mengirim sinyal reboot TR-069 ke ONT pelanggan saat terjadi gangguan koneksi.
* **Force Sync:** Memaksa ONT mengirimkan data terbaru (informasi redaman, uptime, suhu) saat itu juga.
