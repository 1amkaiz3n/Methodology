# ASN & Network Recon (Infrastructure Mapping)

---

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
Mengambil ASN dari domain untuk mengetahui jaringan / provider yang dipakai target.

---

## Extract CIDR Range dari ASN

```bash
# Extract CIDR
cat asn.txt \
| grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+' \
| sort -u \
| tee cidr.txt
```

**Penjelasan:**
Mengambil blok IP (CIDR) dari ASN untuk memperluas attack surface ke level network.

---

## Port Scanning pada CIDR

```bash
# Scan top ports dari seluruh CIDR
cat cidr.txt \
| naabu -top-ports 100 -silent \
| tee ports.txt
```

**Penjelasan:**
Scanning port umum untuk menemukan service terbuka di seluruh jaringan target.

---

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
Memvalidasi service HTTP/HTTPS yang aktif dari hasil port scanning.

---

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
Mencari hostname yang terhubung ke IP untuk mapping infrastruktur tersembunyi.

---

## Filtering PTR yang Menarik

```bash
cat ptr.txt \
| grep -Ei 'dev|test|sta|stage|gw|mail|mx|vpn|admin|api' \
| sort -u \
| tee interesting_ptr.txt
```

**Penjelasan:**
Menyaring hostname yang berpotensi environment sensitif atau internal.

---

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
Mengecek apakah host internal yang ditemukan PTR memiliki service web aktif.

---

## Port Scanning PTR Target

```bash
cat interesting_ptr.txt \
| naabu -top-ports 100 -silent
```

**Penjelasan:**
Scanning port pada host menarik untuk menemukan service tambahan selain HTTP.

---
