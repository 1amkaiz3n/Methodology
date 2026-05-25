# Methodology Recon 403 Bypass

---

## Sub Enum

```bash
subfinder -dL wildcards | anew domains && \
cat wildcards | assetfinder --subs-only | sort -u | anew domains
```

**Penjelasan:**
Tahap ini digunakan untuk mengumpulkan seluruh subdomain yang mungkin terkait dengan target dari berbagai sumber. Hasilnya adalah daftar domain awal yang akan dipakai untuk semua proses recon berikutnya.

**Output:**

* domains → daftar semua subdomain hasil enumerasi
* (sementara belum dicek hidup/mati atau resolvable)

---

## FILTER LIVE HOST

```bash
cat domains | httpx -silent -threads 200 \
-follow-redirects \
-status-code \
-title \
-tech-detect \
-content-length \
-web-server \
-ip \
-cname \
-location \
| tee live_hosts_info
```

**Penjelasan:**
Tahap ini melakukan HTTP probing ke semua subdomain untuk melihat mana yang aktif secara web. Sekaligus mengumpulkan metadata seperti status code, teknologi, IP, server, dan redirect behavior.

**Output:**

* live_hosts_info → daftar host yang aktif beserta detail HTTP response

---

## Filter 403 & 401

BUat Folder untuk hasil recon 403 nya agar tidak bingun dan bercampur
Kenap cuma ambil yang 403 dan 401??karena ini yang kemungminan di lindungi kan tujuan kita bypass

```bash
mkdir 403-Bypass
```

```bash
# Langsung pake grep buat ambil domain 403
cat live_hosts_info   | grep "403" > ../403-Bypass/403.txt
```

**Penjelasan:**
Tahap ini menyaring semua host yang merespons HTTP 403 (Forbidden). Ini penting karena menunjukkan endpoint yang aktif tetapi dibatasi aksesnya.

**Output:**

* 403.txt → daftar host yang menghasilkan response 403

---

## Extract domain

```bash
# ambil domain dari httpx
cat ../403-Bypass/403.txt | awk '{print $1}' | sed 's|https://||g' | cut -d'/' -f1 | sort -u > ../403-Bypass/http_403_domains.txt
```

**Penjelasan:**

* Bagian pertama membersihkan hasil HTTP 403 agar menjadi domain murni tanpa `https://` atau path.
* Bagian kedua mengambil daftar domain hasil resolusi DNS untuk perbandingan.

**Output:**

* http_403_domains.txt → domain yang menghasilkan HTTP 403
* dnsx_domains.txt → domain yang resolve di DNS

---


## DNS RESOLUTION LAYER

```bash
dnsx -l ../403-Bypass/http_403_domains.txt -a -cname -resp -silent -retry 5 > ../403-Bypass/403_resolved_dns.txt
```

**Extrack Domain dari dnsx**

```bash
# ambil domain dari dnsx
cat ../403-Bypass/403_resolved_dns.txt | awk '{print $1}' | sort -u > ../403-Bypass/dnsx_domains.txt
```

**Penjelasan:**
Tahap ini melakukan pengecekan DNS untuk melihat domain mana saja yang benar-benar resolve (aktif di DNS). Sekaligus mengambil informasi A record dan CNAME untuk mengetahui infrastruktur backend.

**Output:**

* 403_resolved_dns.txt → hasil resolusi DNS (A record + CNAME)

---

## Correlation Layer

```bash
# compare
comm -12 ../403-Bypass/dnsx_domains.txt ../403-Bypass/http_403_domains.txt > ../403-Bypass/targets.txt
```

**Penjelasan:**
Tahap ini membandingkan hasil DNS dan HTTP untuk menemukan domain yang:

* terdaftar di DNS (valid)
* sekaligus memiliki response HTTP 403

Ini adalah target prioritas karena menunjukkan service aktif namun dibatasi.

**Output:**

* hasil irisan domain DNS ∩ HTTP 403 (high-value targets)

## WAF DETECTION LAYER


```bash
wafw00f target.com
```

Atau cek semuanya sekaligus

```bash
while read target; do
    echo "Testing: $target"
    wafw00f https://$target -o ../403-Bypass/${target}.json -f json
done < ../403-Bypass/targets.txt
```

## Pisahkan IP

```bash
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' ../403-Bypass/403.txt | anew ../403-Bypass/ips.txt
```

```bash
cat ../403-Bypass/403_resolved_dns.txt | awk '{print $NF}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u | anew ../403-Bypass/ips.txt
```

```bash
# Dedup
sort -u ../403-Bypass/ips.txt -o ../403-Bypass/ips.txt
```

**Penjelasan:**
Mengambil semua IP address dari hasil 403 untuk analisa lebih lanjut seperti shared hosting, IP reuse, atau kemungkinan bypass via direct IP access.

**Output:**

* ips.txt → daftar IP dari target 403

---


## IP REALITY CHECK (HOST HEADER / SHARED IP)

```bash
httpx -l ../403-Bypass/ips.txt -ip -status-code -title -web-server -tech-detect -content-length -location  > ../403-Bypass/ip_probe.txt
```

**Tujuan :**
  - cek apakah 1 IP dipakai banyak domain
  - cari “backend leakage”

**👉 ini buat lihat :**
  - IP reuse
  - service beda domain tapi satu origin



## Cek IP

### Cari IP dengan Response 200

```bash
cat ../403-Bypass/ip_probe.txt | grep 200
```

### Validasi IP

Di tahap ini kita cek IP yang memiliki response 200
Misaalkan IP `194.41.111.123` memiliki response 200,mak kita caru tahu dul ini IP siapa


```bash
curl -sk -I https://194.41.111.123
```

Intinya di tahap ini kita cari subdomain dengan response `403`,tapi ketika akses IP nya langsung, mendapatkan response `200`


### Access via correct Host header 

```bash
curl -vk https://194.41.111.123 -H "Host: crl.post.ch"
```

### Test root only (OCSP behavior)

```bash
curl -vk https://194.41.111.123/
```

### Test method berbeda (kadang filtering beda)

```bash
curl -vk -X POST https://194.41.111.123/
curl -vk -X OPTIONS https://194.41.111.123/
```

### Test path yang memang relevan PKI (bukan web app)

```bash
curl -vk https://194.41.111.123/ocsp
curl -vk https://194.41.111.123/crl
```

### test sensitive path

```bash
curl -vk https://194.41.111.123/.well-known/
curl -vk https://194.41.111.123/debug
```

### Brute force path

```bash
ffuf -w /wordlists/SecLists/Discovery/Web-Content/raft-medium-directories.txt:FUZZ -u https://194.41.111.123/FUZZ
```

## File Output :

* domains → daftar seluruh subdomain hasil enumerasi awal
* resolved_dns → hasil DNS resolution (A record, multi-IP, CNAME chain)
* live_hosts_info → hasil HTTP probing lengkap (status, IP, tech stack, redirect, title)
* 403.txt → daftar endpoint yang mengembalikan HTTP 403
* ips.txt → kumpulan seluruh IP hasil ekstraksi dari DNS + HTTP layer
* host_ip_map.txt → mapping domain ↔ IP untuk analisa shared infra / origin reuse
* http_403_domains.txt → domain hasil filter HTTP 403 (clean format)
* dnsx_domains.txt → domain yang berhasil resolve di DNS
* targets.txt → hasil correlation domain DNS valid + HTTP 403
* ip_probe.txt → hasil probing langsung ke IP (status, title, backend behavior)

