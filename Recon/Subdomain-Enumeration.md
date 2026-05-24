# 📌 Methodology — Subdomain Enumeration

* wildcards → list domain yagn ada di scope



## SUBDOMAIN DISCOVERY (PASSIVE + ACTIVE)

Download Resolver :

```bash
wget https://raw.githubusercontent.com/trickest/resolvers/refs/heads/main/resolvers.txt
```

### Subfinder & asetfinder

```bash
subfinder -dL wildcards | anew domains
cat wildcards | assetfinder --subs-only | sort -u | anew domains
```

## PERMUTATION (EXPANSION)

```bash
# Permutation
cat domains | alterx > alterx_domain.txt
```

## DNS VALIDATION (PASSIVE + PERMUTATION OUTPUT)

```bash
dnsx -l shuffledns.txt -resp -a -cname -silent | anew valid_domains.txt
# atau pake file
dnsx -l alterx_domain.txt -r ~/belajar/bug_bounty/Tools/resolvers.txt -resp -o valid_domains.txt -t 300
```

**MERGE dan DEDUP hasil validasi ke list subdomain**

```bash
# MErge
cat valid_domains.txt | awk '{print $1}' | anew domains
```

```bash
# Dedup
sort -u domains -o domains
```

## HTTP PROBING

```bash
cat domains | httpx -silent -threads 200 | anew hosts
```

## Metadata Fingerprinting

```bash
# HTTP probing detail (fingerprinting + metadata)
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


## Versi satu baris

**Perintah ini menjalankan :**
  - subfinder
  - assetfinder
  - httpx
  - alterx
  - shuffledns
  - dnsx

```bash id="s1"
subfinder -dL wildcards | anew domains && \
cat wildcards | assetfinder --subs-only | sort -u | anew domains && \
cat domains | alterx -o alterx_domains.txt && \
shuffledns -mode resolve -l alterx_domains.txt -r ~/belajar/bug_bounty/Tools/resolvers.txt -o resolved.txt && \
dnsx -l resolved.txt -resp -a -cname -silent | anew valid_domains.txt && \
cat valid_domains.txt | awk '{print $1}' | anew domains && \
cat domains | httpx -silent -threads 200 -follow-redirects -status-code -title -tech-detect -content-length -web-server -ip -cname -location | tee live_hosts_info
```

OUtput :
  - `domains` -> List subdomain
  - `alterx_domains.txt` -> **hasil permutasi / expansion subdomain**
  - `resolved.txt` -> hasil **shuffledns resolve (domain yang benar-benar resolve DNS)**
  - `valid_domains.txt` -> hasil **dnsx validation (A / CNAME resolved host)**
  - `hosts` -> **live HTTP endpoints (minimal info / status check)**
  - `live_hosts_info` -> **live HTTP hosts + full metadata fingerprinting**


## BRUTE FORCE

```bash
wget https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://github.com/trickest/resolvers/blob/main/resolvers.txt
```

### shuffledns

```bash
shuffledns -mode bruteforce -d target.com -w ~/belajar/bug_bounty/Tools/best-dns-wordlist.txt -r ~/belajar/bug_bounty/Tools/resolvers.txt -o brute_subdomain.txt
```


## ACTIVE ATTACK SURFACE DISCOVERY



### DNS BRUTE FORCE (Active Subdomain Enumeration)

```bash
gobuster dns -d target.com -w wordlist.txt
mksub -d target.com -l2 -w dns-wordlist.txt
```

👉 Tujuan:

* mencari subdomain dari wordlist
* query langsung ke DNS authoritative



### VIRTUAL HOST FUZZING (HTTP Layer Discovery)

```bash
ffuf -c -r \
-u 'https://www.target.com/' \
-H 'Host: FUZZ.target.com' \
-w dns-wordlist.txt
```

👉 Tujuan:

* menemukan hidden apps di IP yang sama
* bypass DNS record (tanpa subdomain exist pun bisa valid)



## REVERSE DNS / IP INTELLIGENCE (INFRASTRUCTURE MAPPING)

```bash
# Ambil IP dari host aktif
cat domains | httpx -ip -silent -o hosts_with_ip.txt

# Filter ambil hanya IP
cat hosts_with_ip.txt | awk -F'[][]' '{print $2}' | sort -u > ips.txt
```

```bash
# PTR lookup (reverse DNS)
cat ips.txt | dnsx -ptr -resp-only > dns_lookups.txt
```

👉 Tujuan:

* mapping IP → hostname
* menemukan asset tersembunyi dalam satu infra
* deteksi shared hosting / cluster


