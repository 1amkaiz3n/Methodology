Aku rapihin **struktur, urutan, dan judul section saja** tanpa mengubah 1 karakter pun dari command yang kamu tulis.

---

# 📌 Methodology — Subdomain Enumeration

* wildcards → list domain yagn ada di scope

---

## 1. SUBDOMAIN DISCOVERY (PASSIVE + ACTIVE)

### Subfinder & asetfinder

```bash
subfinder -dL wildcards | anew domains
cat wildcards | assetfinder --subs-only | sort -u | anew domains

# Merge + Deduplicate
sort -u domains -o domains
```

---

## 2. PERMUTATION (EXPANSION)

```bash
# Permutation
cat domains | alterx > alterx_domain.txt
```

---

## 3. DNS VALIDATION (PASSIVE + PERMUTATION OUTPUT)

```bash
dnsx -l alterx_domain.txt -resp -o valid_domains.txt

# atau pake file
dnsx -l alterx_domain.txt -r ~/belajar/bug_bounty/Tools/resolvers.txt -resp -o valid_domains.txt -t 300
```

```bash
# MERGE hasil validasi ke list subdoain 
cat valid_domains.txt | sort -u | anew domains
```

---

## 4. HTTP PROBING

```bash
cat domains | httpx -silent -threads 200 | anew hosts
```

---

## 5. BRUTE FORCE

```bash
wget https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt
wget https://github.com/trickest/resolvers/blob/main/resolvers.txt
```

### shuffledns

```bash
shuffledns -mode bruteforce -d target.com -w ~/belajar/bug_bounty/Tools/best-dns-wordlist.txt -r ~/belajar/bug_bounty/Tools/resolvers.txt -o brute_subdomain.txt
```

### puredns

```bash
puredns bruteforce ~/belajar/bug_bounty/Tools/best-dns-wordlist.txt example.com -r ~/belajar/bug_bounty/Tools/resolvers.txt -w brute_subdomain.txt
```

---

## 6. ACTIVE ATTACK SURFACE DISCOVERY

---

### 6.1 DNS BRUTE FORCE (Active Subdomain Enumeration)

```bash
gobuster dns -d target.com -w wordlist.txt
mksub -d target.com -l2 -w dns-wordlist.txt
```

👉 Tujuan:

* mencari subdomain dari wordlist
* query langsung ke DNS authoritative

---

### 6.2 VIRTUAL HOST FUZZING (HTTP Layer Discovery)

```bash
ffuf -c -r \
-u 'https://www.target.com/' \
-H 'Host: FUZZ.target.com' \
-w dns-wordlist.txt
```

👉 Tujuan:

* menemukan hidden apps di IP yang sama
* bypass DNS record (tanpa subdomain exist pun bisa valid)

---

## 7. REVERSE DNS / IP INTELLIGENCE (INFRASTRUCTURE MAPPING)

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

---
