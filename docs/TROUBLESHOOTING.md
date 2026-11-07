# 🛠️ Panduan Pemecahan Masalah (Troubleshooting)

Kumpulan solusi untuk kendala umum yang sering terjadi di lapangan pada integrasi GenieACS & EugineBill.

---

## 1. Perangkat ONT Tidak Muncul di GenieACS / EugineBill

**Gejala:** Modem sudah diisi ACS URL, tapi tidak muncul di daftar perangkat setelah 5 menit.

**Penyebab & Solusi:**
1. **Cloudflare Proxy Masih Aktif (Paling Sering Terjadi):**
   * Periksa di dashboard Cloudflare DNS. Pastikan `acs.euginemediagroup.site` statusnya adalah **DNS Only (Awan Abu-abu)**.
   * Jika masih Awan Orange (Proxied), Cloudflare akan menolak koneksi port `7547` dari modem.
2. **Port 7547 Tertutup di AWS Security Group:**
   * Masuk ke AWS Console → EC2 → Security Groups.
   * Pastikan ada aturan Inbound: `Custom TCP | Port 7547 | Source 0.0.0.0/0`.
3. **Routing WAN ONT ke Server:**
   * Jika ONT menggunakan IP private (misal IP PPPoE lokal `10.x.x.x`), pastikan router Mikrotik Anda memiliki gateway internet / NAT masquerade agar IP lokal ONT bisa menjangkau IP publik server EC2.
   * Uji dari Mikrotik: `ping acs.euginemediagroup.site`.

---

## 2. Redaman Menampilkan "N/A"

**Gejala:** ONT muncul dan status online, tetapi nilai redaman (RX Power) tertulis `N/A`.

**Penyebab & Solusi:**
1. **Virtual Parameters Belum Diimpor:**
   * Di terminal server EC2, jalankan ulang:
     ```bash
     cd ~/project-redaman
     bash scripts/import-vps.sh
     ```
2. **Vendor ONT Menggunakan OID Khusus:**
   * Masuk ke GenieACS UI (`http://acs.euginemediagroup.site:3000`).
   * Klik perangkat tersebut → buka tab **Parameters**.
   * Cari kata kunci `Optical` atau `RXPower` atau `RxPower` untuk melihat path yang digunakan oleh firmware ONT tersebut.
   * Tambahkan path baru tersebut ke dalam file `virtual-parameters/RXPower.js`, lalu import ulang.

---

## 3. Tugas (Task) Edit WiFi / Reboot Berstatus "Pending" Lama

**Gejala:** Saat klik Update WiFi dari EugineBill, status task kuning (*Pending*) dan tidak langsung sukses.

**Penyebab:**
* Modem pelanggan berada di belakang NAT (IP Private) sehingga GenieACS tidak bisa mengirim sinyal *Connection Request* secara instan ke port 7547 ONT.

**Solusi:**
* **Normal Behavior:** Perubahan parameter akan otomatis diterapkan pada saat modem mengirimkan **Periodic Inform berikutnya** (maksimal 5 menit sesuai interval).
* **Solusi Instan:** Jika ingin langsung instan tanpa menunggu 5 menit, aktifkan opsi **STUN Client** di TR-069 setting pada modem ONT.

---

## 4. Cara Cek Log Kontainer di Server

Jika ingin memantau komunikasi real-time saat modem dicolok:

```bash
# Pantau lalu lintas TR-069 yang masuk
docker compose logs -f genieacs-cwmp

# Pantau API call dari EugineBill
docker compose logs -f genieacs-nbi

# Restart seluruh layanan
docker compose restart
```
