# 📌 Methodology — Subdomain Enumeration

* wildcards → list domain yagn ada di scope
Contoh :
  - sub.target.com
  - sub2.target.com


## SUBDOMAIN DISCOVERY (PASSIVE + ACTIVE)

Download Resolver :

```bash
wget https://raw.githubusercontent.com/trickest/resolvers/refs/heads/main/resolvers.txt
```

### Subfinder,asetfinder,chaos,github-domain,crt.sh,bbot

```bash
subfinder -silent -dL wildcards | anew domains
while read domain; do assetfinder --subs-only "$domain"; done | anew domains
chaos -silent -dL wildcards | anew domains
```

```bash
bbot -t wildcards -p subdomain-enum -o bbot-output
```
> **BBBOT ini akan menghaislkn folder `bbot-output`,dan di dalalmnay ada beberpa file seprti `subdomains.txt`**

Pindahin hasil bbot ke file domains

```bash
find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains
```

```bash
cat wildcards | while read domain; do
  github-subdomains -d "$domain" -raw
done | grep -v 'https://' | grep -v '^\[' | anew domains
```

```bash
cat wildcards | while read domain; do
  curl -s "https://crt.sh/?q=%.$domain&output=json" \
    | grep -v '^<' \
    | jq -r '.[].name_value' 2>/dev/null \
    | sed 's/\*\.//g' \
    | tr ',' '\n' \
    | grep -v '^\*' \
    | grep "\.$domain$"
done | sort -u | anew domains
```

## PERMUTATION (EXPANSION)

```bash
# Permutation
cat domains | alterx > alterx_domain.txt
```

## DNS VALIDATION (PASSIVE + PERMUTATION OUTPUT)

```bash
dnsx -l domains -resp -a -cname -silent | anew valid_domains.txt
# atau pake file
dnsx -l alterx_domain.txt -r /resolvers.txt -resp -o valid_domains.txt -t 300
# shuffledns
shuffledns -mode resolve -l alterx_domains.txt -r /resolvers.txt -o resolved.txt -t 50
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
httpx -l domains -silent -threads 200 | anew hosts
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
subfinder -silent -dL wildcards | anew domains && \
assetfinder --subs-only $(cat wildcards) | anew domains && \
bbot -t wildcards -p subdomain-enum -o bbot-output && \
find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains && \
cat wildcards | while read domain; do
  curl -s "https://crt.sh/?q=%.$domain&output=json" \
    | grep -v '^<' \
    | jq -r '.[].name_value' 2>/dev/null \
    | sed 's/\*\.//g' \
    | tr ',' '\n' \
    | grep -v '^\*' \
    | grep "\.$domain$"
done | anew domains && \
chaos -dL wildcards | anew domains && \
cat wildcards | while read domain; do
  github-subdomains -d "$domain" -raw
done | grep -v 'https://' | grep -v '^\[' | anew domains && \
dnsx -l domains -resp -a -cname -silent | anew valid_domains.txt && \
awk '{print $1}' valid_domains.txt | anew domains && \
httpx -l domains -silent -threads 200 -follow-redirects -status-code -title -tech-detect -content-length -web-server -ip -cname -location | tee live_hosts_info
```

OUtput :
  - `domains` -> List subdomain
  - `alterx_domains.txt` -> **hasil permutasi / expansion subdomain**
  - `resolved.txt` -> hasil **shuffledns resolve (domain yang benar-benar resolve DNS)**
  - `valid_domains.txt` -> hasil **dnsx validation (A / CNAME resolved host)**
  - `hosts` -> **live HTTP endpoints (minimal info / status check)**
  - `live_hosts_info` -> **live HTTP hosts + full metadata fingerprinting**
