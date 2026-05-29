# Quick Recon Toolkit

## SUBDOMAIN DISCOVERY 

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

## HTTP Probing & Infrastructure Fingerprinting

```bash
cat domains.txt | httpx -silent -threads 200 \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -ip \
  -cname \
  -location \
  -o live_hosts_info.txt
```

```bash
cat live_hosts_info.txt | awk '{print $1}' | sort -u | anew hosts.txt
```

## URL Collection & Analysis

```bash
katana -list hosts.txt -d 5 -jc -kf all | anew urls.txt
```

```bash
cat hosts.txt | waybackurls |  anew urls.txt
```

```bash
cat hosts.txt | hakrawler -d 3 | anew urls.txt
```

```bash
gau --subs < hosts.txt | sort -u | anew urls.txt
```


## Parameter Extraction

```bash
cat urls.txt | grep "=" > params.txt
```

## Sensitive File Discovery

