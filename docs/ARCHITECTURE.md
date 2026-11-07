# 🏗️ Arsitektur Sistem & Spesifikasi Teknis (Multi-Tenant)

Server ini dikonfigurasi untuk menjalankan **dua instance GenieACS mandiri** dalam 1 server Ubuntu EC2 menggunakan Docker Compose dan MongoDB shared engine dengan database terpisah.

---

## 1. Perbandingan Instance Client 1 vs Client 2

| Parameter | Instance 1 (Client 1) | Instance 2 (Client 2) |
| :--- | :--- | :--- |
| **Domain Host** | `acs.euginemediagroup.site` | `acs2.euginemediagroup.site` |
| **CWMP Port (Untuk ONT)** | **`7547`** | **`7548`** |
| **NBI Port (Untuk EugineBill)** | **`7557`** | **`7558`** |
| **Admin Web UI Port** | **`3000`** | **`3001`** |
| **File Server (FS) Port** | `7567` | `7568` |
| **Database MongoDB** | `genieacs` | `genieacs2` |
| **Data Storage FS** | `./data/fs` | `./data/fs-client2` |
| **Isolasi Data** | Terpisah 100% | Terpisah 100% |

---

## 2. Diagram Multi-Tenant

```
                                  [ INTERNET ]
                                        │
           ┌────────────────────────────┴────────────────────────────┐
           │                                                         │
   Domain: acs.euginemediagroup.site           Domain: acs2.euginemediagroup.site
           │                                                         │
           ▼                                                         ▼
[AWS EC2: 16.176.198.126]                   [AWS EC2: 16.176.198.126]
┌───────────────────────────────────────┐   ┌───────────────────────────────────────┐
│ INSTANCE 1 (CLIENT 1)                 │   │ INSTANCE 2 (CLIENT 2)                 │
│                                       │   │                                       │
│ • CWMP: Port 7547 (ONT Client 1)      │   │ • CWMP: Port 7548 (ONT Client 2)      │
│ • NBI : Port 7557 (EugineBill 1)      │   │ • NBI : Port 7558 (EugineBill 2)      │
│ • UI  : Port 3000                     │   │ • UI  : Port 3001                     │
└──────────────────┬────────────────────┘   └───────────────────┬───────────────────┘
                   │                                            │
                   │ db: "genieacs"                             │ db: "genieacs2"
                   ▼                                            ▼
           ┌────────────────────────────────────────────────────────────┐
           │                     MONGODB 6.0 ENGINE                     │
           │      (Satu container efisien, data terpisah 100%)          │
           └────────────────────────────────────────────────────────────┘
```

---

## 3. Rincian Port AWS Security Group yang Wajib Terbuka

Pastikan Inbound Rules di AWS Security Group mencakup:

* **Client 1:**
  * `7547` (TCP) - CWMP
  * `7557` (TCP) - NBI REST API
  * `3000` (TCP) - Web UI
* **Client 2:**
  * `7548` (TCP) - CWMP
  * `7558` (TCP) - NBI REST API
  * `3001` (TCP) - Web UI
