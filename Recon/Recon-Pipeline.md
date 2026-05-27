# 🧭 RECON PIPELINE FULL

## Domains Enumeration


```bash
subfinder -silent -dL wildcards | anew domains.txt && cat wildcards | while read domain; do assetfinder --subs-only "$domain"; done | anew domains.txt && chaos -dL wildcards -silent | anew domains.txt && bbot -t wildcards -p subdomain-enum -s -o bbot-output && find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains.txt && cat wildcards | while read domain; do github-subdomains -d "$domain" -raw; done | grep -v 'https://' | grep -v '^\[' | anew domains.txt && cat wildcards | while read domain; do curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -v '^<' | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | tr ',' '\n' | grep -v '^\*' | grep "\.$domain$"; done | sort -u | anew domains.txt && sort -u domains.txt -o domains.txt
```

## DNS Resolution + IP Maping

```bash
dnsx -l domains.txt -a -resp-only -silent -o ips.txt && sort -u ips.txt -o ips.txt && dnsx -l domains.txt -silent -o live_domains.txt
```

## Metadata Fingerprinting



```bash
cat live_domains.txt | httpx -silent -threads 200 \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -ip \
  -cname \
  -location \
  | tee live_hosts_info.txt \
  | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' \
  | anew ips.txt && \
awk '{print $1}' live_hosts_info.txt | anew hosts.txt
```


## Port Scanning (INFRA CHECK)

**PORT DISCOVERY**
```bash
naabu -list ips.txt -c 50 -o ports.txt
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


## one-Liner Subdomain Enumerartion,fingerprinting

```bash
subfinder -silent -dL wildcards | anew domains.txt && cat wildcards | while read domain; do assetfinder --subs-only "$domain"; done | anew domains.txt && chaos -dL wildcards | anew domains.txt && bbot -t wildcards -p subdomain-enum -s -o bbot-output && find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains.txt && cat wildcards | while read domain; do github-subdomains -d "$domain" -raw; done | grep -v 'https://' | grep -v '^\[' | anew domains.txt && cat wildcards | while read domain; do curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -v '^<' | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | tr ',' '\n' | grep -v '^\*' | grep "\.$domain$"; done | sort -u | anew domains.txt && sort -u domains.txt -o domains.txt && dnsx -l domains.txt -a -resp-only -silent -o ips.txt && sort -u ips.txt -o ips.txt && dnsx -l domains.txt -silent -o live_domains.txt && cat live_domains.txt | httpx -silent -threads 200 -follow-redirects -status-code -title -tech-detect -content-length -web-server -ip -cname -location | tee live_hosts_info.txt | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | anew ips.txt && awk '{print $1}' live_hosts_info.txt | anew hosts.txt && naabu -list ips.txt -c 50 -o ports.txt
```