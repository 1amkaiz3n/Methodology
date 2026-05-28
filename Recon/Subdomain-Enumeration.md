# 📌 Subdomain Enumeration

* wildcards → list domain yagn ada di scope
Contoh :
  - sub.target.com
  - sub2.target.com


## SUBDOMAIN DISCOVERY (PASSIVE + ACTIVE)
`

### Subfinder,asetfinder,chaos,github-domain,crt.sh,bbot

```bash
subfinder -silent -dL wildcards | anew domains.txt
cat wildcards | assetfinder --subs-only | anew domains.txt
chaos -silent -dL wildcards | anew domains.txt
```

```bash
bbot -t wildcards -p subdomain-enum -o bbot-output
```
> **BBBOT ini akan menghaislkn folder `bbot-output`,dan di dalalmnay ada beberpa file seprti `subdomains.txt`**

Pindahin hasil bbot ke file domains.txt

```bash
find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains.txt
```

```bash
cat wildcards | while read domain; do
  github-subdomains -d "$domain" -raw
done | grep -v 'https://' | grep -v '^\[' | anew domains.txt
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
done | sort -u | anew domains.txt
```
Dedup

```bash
sort -u domains.txt -o domains.txt
```

## DNS Validations

```bash
dnsx -l domains.txt -silent -a -cname -resp -o resolved.txt
```

## HTTP Probing & Infrastructure Fingerprinting


```bash
cat resolved.txt | awk '{print $1}' | sort -u | httpx -silent -threads 200 \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -ip \
  -cname \
  -location \
  | tee live_hosts_info.txt 
```


## Versi satu baris


```bash id="s1"
subfinder -silent -dL wildcards | anew domains.txt && \
cat wildcards | while read domain; do assetfinder --subs-only "$domain"; done | anew domains.txt && \
chaos -dL wildcards | anew domains.txt && \
cat wildcards | while read domain; do github-subdomains -d "$domain" -raw; done | grep -v 'https://' | grep -v '^\[' | anew domains.txt && \
cat wildcards | while read domain; do curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -v '^<' | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | tr ',' '\n' | grep -v '^\*' | grep "\.$domain$"; done | sort -u | anew domains.txt && \
sort -u domains.txt -o domains.txt && \
dnsx -l domains.txt -silent -a -cname -resp | awk '{print $1}' | sort -u | httpx -silent -threads 200 \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -ip \
  -cname \
  -location \
  | tee live_hosts_info.txt
```

OUtput :
  - `domains.txt` -> List subdomain
  - `domains` -> hasil **dnsx validation (A / CNAME resolved host)**
  - `hosts.txt` -> **live HTTP endpoints (minimal info / status check)**
  - `live_hosts_info` -> **live HTTP hosts + full metadata fingerprinting**
