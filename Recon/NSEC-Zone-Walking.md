# NSEC Zone Walking

## Overview

NSEC Zone Walking adalah teknik enumerasi DNS yang memanfaatkan **DNSSEC (NSEC record)** untuk mengetahui struktur domain dalam suatu zone. Ini bukan brute force, tapi hasil dari cara DNSSEC membuktikan bahwa suatu domain tidak ada (NXDOMAIN proof).


## Cara Kerja

DNSSEC memakai **NSEC (Next Secure Record)** untuk membuktikan “domain ini tidak ada”.

NSEC juga mengungkap:

* urutan domain dalam zone DNS
* range domain yang valid
* tipe record yang tersedia
* signature validasi (RRSIG)

Dari sini attacker bisa melakukan enumerasi struktur domain.


## Perintah Identifikasi

### 1. Cek DNSSEC (DNSKEY)

```bash 
dig domain.com DNSKEY
```

**Output (contoh normal)**

```bash id="dnskey_out1"
;; ANSWER SECTION:
domain.com. 3600 IN DNSKEY 257 3 13 AwEAAc...
domain.com. 3600 IN RRSIG DNSKEY 13 2 3600 ...
```



### 2. Cek NSEC record

```bash 
dig domain.com NSEC
```

**Output (vulnerable)**

```bash 
domain.com. IN NSEC \
\000.domain.com. A PTR HINFO MX TXT RP AAAA SRV NAPTR RRSIG NSEC
```



### 3. Cek NSEC3 (lebih aman)

```bash 
dig domain.com NSEC3
```

**Output (aman)**

```bash id="nsec3_out"
;; ANSWER SECTION:
domain.com. IN NSEC3 1 1 10 A1B2C3D4...
```



### 4. Cek DNSSEC detail (paling penting)

```bash 
dig +dnssec domain.com
```

**Output (vulnerable indicator)**

```bash 
domain.com. IN NSEC \
\000.domain.com. A MX TXT AAAA SRV NAPTR RRSIG NSEC
```



## Lanjutan yang harus di lakukan

### cari NXDOMAIN behavior

```bash
dig random123.target.com
```

### cari possible sibling domain


```bash
dig mail.target.com
dig api.target.com
dig vpn.target.com
```

### cek apakah ada “range leakage”

\000.www → next domain

```bash
\000.www → next domain
```
➡️ ini tanda zone bisa di-iterate


## Indikator Vulnerability

✔ DNSSEC aktif (DNSKEY + RRSIG ada)
✔ NSEC record muncul di response
✔ NXDOMAIN response mengandung chain / range domain
✔ Bisa enumerasi subdomain secara bertahap



## Dampak

* Subdomain enumeration tanpa brute force
* Discovery hidden / internal services
* Exposure staging / admin / API / VPN endpoint
* Memperluas attack surface target



## Impact Classification

* **Type:** Information Disclosure (DNSSEC / NSEC Exposure)
* **Severity:** Low – Medium
* **CWE:** CWE-200 (Information Exposure)



## Perbedaan dengan Zone Transfer (AXFR)

* **AXFR:** full DNS database leak (misconfiguration, lebih parah)
* **NSEC:** partial disclosure via DNSSEC chain (design behavior)



## Kesimpulan

NSEC Zone Walking bukan exploit aktif, tetapi teknik enumerasi DNS berbasis DNSSEC yang dapat menjadi vulnerability jika memungkinkan rekonstruksi struktur subdomain dan memberikan informasi yang cukup untuk reconnaissance lanjutan atau attack chaining.
