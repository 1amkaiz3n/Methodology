## 🔍 Recon Phase Overview

Tahapan Recon dalam framework ini disusun untuk membangun full attack surface secara sistematis sebelum masuk ke eksploitasi.

### 1. Subdomain Enumeration
Mengumpulkan seluruh subdomain dari berbagai sumber (passive & active) untuk mendapatkan initial attack surface.

Output: `domains`

---

### 2. DNS Recon & Validation
Validasi hasil subdomain, melakukan resolusi DNS, serta identifikasi wildcard dan infrastruktur dasar.

Output: `valid_domains`, `cname`, `resolved IP`

---

### 3. HTTP Probing
Menentukan host yang aktif secara web dan mengumpulkan metadata seperti status code, title, dan teknologi.

Output: `hosts`

---

### 4. ASN & Network Recon
Mapping ASN, CIDR, dan IP range untuk menemukan aset di level infrastruktur.

Output: `asn`, `cidr`, `ports`, `live-network-hosts`

---

### 5. 403 Target Discovery
Identifikasi endpoint yang terbatas (403) untuk mencari potensi bypass dan misconfiguration.

Output: `403 targets`

---

### 6. JavaScript Recon
Analisis file JS untuk menemukan endpoint, secret, API route, dan logic aplikasi.

Sub-tahapan:
- JS URL collection
- Endpoint extraction
- Source/Sink analysis
- JS monitoring

Output: `endpoints`, `secrets`, `api paths`

---

### 7. URL & Parameter Discovery
Mencari endpoint tersembunyi dan parameter yang bisa diinject melalui crawling dan wordlist attack.

Output: `urls`, `parameters`

---

### 8. Tech & Cloud Fingerprinting
Identifikasi teknologi, CDN, cloud provider, dan service backend yang digunakan target.

Output: `stack info`, `CDN`, `cloud mapping`
