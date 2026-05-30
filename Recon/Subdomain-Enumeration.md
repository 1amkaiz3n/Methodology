# 📌 Subdomain Enumeration

* wildcards → list domain yagn ada di scope
Contoh :
  - sub.target.com
  - sub2.target.com


## SUBDOMAIN DISCOVERY (PASSIVE + ACTIVE)

**Subfinder**

```bash
subfinder -silent -dL wildcards | anew domains.txt  &&  && && 
```

**assetfinder**

```bash
while read domain; do
  assetfinder --subs-only "$domain"
done < wildcards | anew domains.txt
```

**chaos**

```bash
chaos -dL wildcards -silent | anew domains.txt
```

**github-subdomains**

```bash
cat wildcards | while read domain; do github-subdomains -d "$domain" -raw; done | grep -v 'https://' | grep -v '^\[' | anew domains.txt
```

**crt.sh**

```bash
while read d; do
  curl -s "https://crt.sh/?q=%25.$d&output=json" \
  | jq -r '.[].name_value' 2>/dev/null
done < wildcards \
| sed 's/\*\.//g' \
| tr ',' '\n' \
| grep -v '^\*' \
| sort -u | anew domains.txt
```

**bbot**

```bash
bbot -t wildcards -p subdomain-enum -s -o bbot-output 
find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains.txt
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
httpx -l resolved.txt -silent -threads 200 \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -server \
  -ip \
  -cname \
  -location \
  -o live_hosts_info.txt
```

```bash
cat live_hosts_info.txt | awk '{print $1}' | sort -u | anew hosts.txt
```

## Versi satu baris


```bash id="s1"
subfinder -silent -dL wildcards | anew domains.txt && \
cat wildcards | assetfinder --subs-only | anew domains.txt && \
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
