# 📌 Methodology ASN & Network Recon (Infrastructure Mapping)

## Tools 
  - unfurl
  - asnmap
  - naabu
  - httpx
  - mapcidr
  - dnsx

## ASN Mapping dari Domain Scope

```bash
# Mapping ASN dari root/apex domain
cat wildcards \
| unfurl apex \
| sort -u \
| asnmap -silent \
| tee asn.txt
```

**Penjelasan:**
Mengambil informasi ASN (Autonomous System Number) dari domain untuk mengetahui provider / jaringan utama yang digunakan target (misalnya AWS, Cloudflare, Google, dll). Ini membantu memahami infrastruktur level awal.

**Output :**
  - menghasilkan informasi jaringan milik target
  - CIDR (range IP milik target)
  - ASN number (identitas jaringan)
  - Provider/Org (cloud/ISP yang dipakai target)

## Extract CIDR Range dari ASN

```bash
# Extract CIDR
cat asn.txt \
| grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+' \
| sort -u \
| tee cidr.txt
```

**Penjelasan:**
Mengambil blok IP (CIDR) dari ASN untuk memperluas scope ke jaringan IP yang mungkin masih milik target tapi belum muncul di subdomain.

**Output :**
  - daftar blok IP (range jaringan)
  - milik provider/cloud yang dipakai target
  - bukan 1 server, tapi kumpulan banyak IP
  - daftar wilayah IP besar tempat semua server target bisa berada

## Port Scanning pada CIDR

```bash
# Scan top ports dari seluruh CIDR
cat cidr.txt \
| naabu -top-ports 100 -silent \
| tee ports.txt
```

**Penjelasan:**
Melakukan scanning port umum untuk menemukan service yang terbuka di seluruh IP range target (HTTP, SSH, API service, dll).

**Output :**
  - daftar IP + port yang terbuka
  - hasil scan dari seluruh CIDR
  - menunjukkan service yang aktif di jaringan target
  - daftar pintu yang terbuka di semua jaringan target


## HTTP Service Probing

```bash
# Probe HTTP service hasil network scan
cat ports.txt \
| httpx -silent \
  -title \
  -tech-detect \
  -status-code \
| tee live-network-hosts.txt
```

**Penjelasan:**
Memvalidasi service web yang aktif dari hasil port scanning dan mengambil informasi penting seperti status code, title, dan teknologi yang digunakan.



## Reverse DNS (PTR Lookup)

```bash
# PTR lookup seluruh IP di CIDR
cat cidr.txt \
| mapcidr -silent \
| dnsx -ptr -resp-only \
| sort -u \
| tee ptr.txt
```

**Penjelasan:**
Melakukan reverse DNS lookup untuk mencari hostname yang terhubung ke IP. Ini berguna untuk menemukan sistem internal yang tidak terlihat di subdomain biasa.

**Output :**
  * daftar hostname hasil reverse DNS
  * mapping IP → domain internal
  * bisa nemuin service tersembunyi (mail, vpn, admin panel)
  * asset internal yang tidak muncul di subdomain enumeration

## Filtering PTR yang Menarik

```bash
cat ptr.txt \
| grep -Ei 'dev|test|sta|stage|gw|mail|mx|vpn|admin|api' \
| sort -u \
| tee interesting_ptr.txt
```

**Penjelasan:**
Menyaring hostname yang kemungkinan besar merupakan environment sensitif seperti development, staging, admin panel, VPN, atau mail server.

**Output :**
  * hostname yang sudah difilter (dev/test/staging/admin/vpn dll)
  * kandidat environment sensitif
  * target prioritas untuk testing lanjut
  * reduced noise dari PTR hasil mentah


## HTTP Probing PTR Target

```bash
cat interesting_ptr.txt \
| httpx -silent \
  -title \
  -tech-detect \
  -status-code \
  -follow-redirects
```

**Penjelasan:**
Memeriksa apakah hostname internal hasil PTR memiliki service web yang aktif dan bisa diakses via HTTP/HTTPS.

**Output :**
  * list host PTR yang aktif HTTP/HTTPS
  * status code tiap host
  * title halaman (indikasi aplikasi)
  * teknologi web yang dipakai (framework/server)
  * endpoint internal yang bisa diakses

## Port Scanning PTR Target

```bash
cat interesting_ptr.txt \
| naabu -top-ports 100 -silent
```

**Penjelasan:**
Melakukan scanning port pada target hasil PTR untuk menemukan service tambahan selain web, seperti SSH, database, atau API internal.

**Output :**
  * daftar IP/hostname + port terbuka
  * service non-web (SSH, DB, API internal)
  * potensi entry point tambahan selain HTTP
  * attack surface tambahan dari hasil PTR