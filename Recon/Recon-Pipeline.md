# 🧭 RECON PIPELINE FULL

## Domains Enumeration


```bash
subfinder -silent -dL wildcards | anew domains.txt && cat wildcards | while read domain; do assetfinder --subs-only "$domain"; done | anew domains.txt && chaos -dL wildcards -silent | anew domains.txt && cat wildcards | while read domain; do github-subdomains -d "$domain" -raw; done | grep -v 'https://' | grep -v '^\[' | anew domains.txt && cat wildcards | while read domain; do curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -v '^<' | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | tr ',' '\n' | grep -v '^\*' | grep "\.$domain$"; done | sort -u | anew domains.txt && sort -u domains.txt -o domains.txt
```

```bash
bbot -t wildcards -p subdomain-enum -s -o bbot-output 
find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains.txt
```

## DNS Resolution + IP Maping

```bash
dnsx -l domains.txt -a -resp-only -silent -o ips.txt
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

Dedup
```bash
sort -u ips.txt -o ips.txt
```

## Filter Cloudflare IP

```bash
grep -vE "104\.|172\.64|172\.6[4-9]" ips.txt > real.txt
```
Atau,untuk filter juga private IP

```bash
cat ips.txt \
| sort -u \
| grep -vE '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1]))' \
| grep -vE '^104\.|^172\.64\.|^172\.6[4-9]\.' \
> real.txt
```

## Port Scanning (INFRA CHECK)

**PORT DISCOVERY**
```bash
naabu -silent -list real.txt -c 50 -o ports.txt
```

```bash
naabu -list real.txt -p 21,22,23,25,53,80,110,111,135,139,143,389,443,445,465,587,993,995,1433,1521,2049,3306,3389,5432,6379,8080,8443,9000 -c 100 -o ports.txt
```

**DIRECT PER-IP NMAP**

```bash
mkdir -p nmap && \
awk '!seen[$0]++' ports.txt | \
awk -F: '{print $1,$2}' | \
while read ip port; do
  nmap -sV -sC -p $port $ip -oN "nmap/nmap_${ip}_${port}.txt"
done
```

## HTTP test AWS LB (jangan port scan ini)

```bash
cat real.txt | grep -E '^(108\.|13\.)' | while read ip; do
  curl -sk https://$ip -I --connect-timeout 3 | head
done
```

## one-Liner Subdomain Enumeration,fingerprinting,port scanning

```bash
subfinder -silent -dL wildcards | anew domains.txt && \
cat wildcards | while read domain; do assetfinder --subs-only "$domain"; done | anew domains.txt && \
chaos -dL wildcards | anew domains.txt && \
cat wildcards | while read domain; do github-subdomains -d "$domain" -raw; done | grep -v 'https://' | grep -v '^\[' | anew domains.txt && \
cat wildcards | while read domain; do curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -v '^<' | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | tr ',' '\n' | grep -v '^\*' | grep "\.$domain$"; done | sort -u | anew domains.txt && \
sort -u domains.txt -o domains.txt && \
dnsx -l domains.txt -a -resp-only -silent -o ips.txt && \
sort -u ips.txt -o ips.txt && \
cat domains.txt | httpx -silent -threads 200 -follow-redirects -status-code -title -tech-detect -content-length -web-server -ip -cname -location | tee live_hosts_info.txt | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | anew ips.txt && \
awk '{print $1}' live_hosts_info.txt | anew hosts.txt && \
naabu -silent -list ips.txt -c 50 -o ports.txt
```