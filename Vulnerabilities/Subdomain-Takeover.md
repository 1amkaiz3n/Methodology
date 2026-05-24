# Metodologi Subdomain TakeOver

## 1. Subdomain Enumeration

```bash
subfinder -dL wildcards | tee domains

cat wildcard | assetfinder --subs-only | anew domains
```

### Tambahan Source Passive Recon

```bash
# crt.sh
cat wildcards | while read domain; do
  curl -s "https://crt.sh/?q=%.$domain&output=json" \
    | grep -v '^<' \
    | jq -r '.[].name_value' 2>/dev/null \
    | sed 's/\*\.//g' \
    | tr ',' '\n' \
    | grep -v '^\*' \
    | grep "\.$domain$"
done | sort -u | anew domains

# chaos (ProjectDiscovery)
chaos -dL wildcards | anew domains

# github-subdomains
cat wildcards | while read domain; do
  github-subdomains -d "$domain" -raw
done | grep -v 'https://' | grep -v '^\[' | anew domains

```



## 2. Active DNS Bruteforce

```bash
# puredns bruteforce
puredns bruteforce wordlists/best-dns-wordlist.txt target.com \
  --resolvers resolvers.txt | anew domains

# alterx - generate variasi subdomain
alterx -list domains -enrich | puredns resolve \
  --resolvers resolvers.txt | anew domains
```



## 3. Live Hosts Validation

```bash
cat domains \
| httpx -silent -threads 200 \
| anew hosts
```



## 4. DNS Recon

```bash
uvx run dnsrecon -d domain.com
```



## 5. CNAME Enumeration & Manual Check

### Tes CNAME (manual check per host)

```bash
cat hosts | sed 's|https\?://||' | while read d; do
  echo "==== $d ===="
  dig +short $d cname
done
```

```bash
cat hosts | sed 's|https\?://||' | while read d; do
  cname=$(dig +short "$d" cname)
  if echo "$cname" | grep -Eqi 'elasticbeanstalk\.com|s3\.amazonaws\.com|animaapp\.io|bitbucket\.io|trydiscourse\.com|helpjuice\.com|helpscoutdocs\.com|helprace\.com|cloudapp\.net|cloudapp\.azure\.com|azurewebsites\.net|blob\.core\.windows\.net|azure-api\.net|azurehdinsight\.net|azureedge\.net|azurecontainer\.io|database\.windows\.net|azuredatalakestore\.net|search\.windows\.net|azurecr\.io|redis\.cache\.windows\.net|servicebus\.windows\.net|visualstudio\.com|s\.strikinglydns\.com|surveysparrow\.com|read\.uberflip\.com|wordpress\.com|worksites\.net|github\.io'; then
    echo "[POTENTIAL] $d -> $cname"
  fi
done
```



## 6. CNAME Extraction (Automated)

```bash
cat domains | dnsx -silent -resp-only -cname | tee cname.txt

# atau

cat domains | while read d; do
    dig +short CNAME $d
done
```



## 7. Provider Fingerprinting (SaaS Detection)

```bash
cat domains | grep -Ei \
"herokuapp|github\.io|pages\.dev|cloudfront|fastly|zendesk|freshdesk|desk\.com|readme\.io|statuspage|unbounce|wpengine|pantheonsite|helpscout|surge\.sh|netlify|vercel|firebaseapp|webflow|ghost|uservoice|cargocollective|teamwork|atlassian|azure"
```

```bash
# list vuln dari i can takeover
cat domains | grep -Ei \
"elasticbeanstalk.com|s3.amazonaws.com|airee.ru|animaapp.io|bitbucket.io|trydiscourse.com|hatenablog.com|helpjuice.com|helpscoutdocs.com|helprace.com|cloudapp.net|cloudapp.net, cloudapp.azure.com|azurewebsites.net|blob.core.windows.net|cloudapp.azure.com|azure-api.net|azurehdinsight.net|azureedge.net|azurecontainer.io|database.windows.net|azuredatalakestore.net|search.windows.net|azurecr.io|redis.cache.windows.net|azurehdinsight.net|servicebus.windows.net|visualstudio.com|52.16.160.97|s.strikinglydns.com|na-west1.surge.sh|surveysparrow.com|read.uberflip.com|wordpress.com|worksites.net|69.164.223.206|github\.io"
```

```bash
cat cname.txt | grep -Ei \
"azure|heroku|github|pages|zendesk|fastly|cloudfront|netlify|vercel|statuspage|readme|freshdesk|atlassian"

cat cname.txt | grep -Ei \
"elasticbeanstalk.com|s3.amazonaws.com|airee.ru|animaapp.io|bitbucket.io|trydiscourse.com|hatenablog.com|helpjuice.com|helpscoutdocs.com|helprace.com|cloudapp.net|cloudapp.net, cloudapp.azure.com|azurewebsites.net|blob.core.windows.net|cloudapp.azure.com|azure-api.net|azurehdinsight.net|azureedge.net|azurecontainer.io|database.windows.net|azuredatalakestore.net|search.windows.net|azurecr.io|redis.cache.windows.net|azurehdinsight.net|servicebus.windows.net|visualstudio.com|52.16.160.97|s.strikinglydns.com|na-west1.surge.sh|surveysparrow.com|read.uberflip.com|wordpress.com|worksites.net|69.164.223.206|github\.io"
```



## 8. NS Takeover Check

```bash
# Cek NS record yang pointing ke registrar yang bisa diklaim
cat domains | while read d; do
  ns=$(dig +short NS "$d")
  if echo "$ns" | grep -Eqi \
    "afraid\.org|registrar-servers\.com|bodis\.com|parkingcrew\.net|sedoparking\.com|above\.com"; then
    echo "[NS-TAKEOVER POTENTIAL] $d -> $ns"
  fi
done
```



## 9. Takeover Check Script (Dig Based)

```bash
vim takeover-check.sh
```

```bash
#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

check() {
  domain="$1"

  cname=$(dig +short CNAME "$domain" | tr -d '\n' | head -1)

  # NO CNAME
  if [ -z "$cname" ]; then
    a=$(dig +short A "$domain" | tr -d '\n')

    if [ -n "$a" ]; then
      echo -e "${GREEN}[OK]${NC} $domain -> A $a"
    else
      echo -e "${BLUE}[NO-DNS]${NC} $domain"
    fi
    return
  fi

  # resolve final target (follow chain simple loop)
  final="$cname"
  while true; do
    next=$(dig +short CNAME "$final" | tr -d '\n')
    [ -z "$next" ] && break
    final="$next"
  done

  # CHECK A RECORD FINAL TARGET
  a=$(dig +short A "$final" | tr -d '\n')

  if [ -z "$a" ]; then
    # ONLY THIS IS POTENTIAL
    echo -e "${RED}[POTENTIAL]${NC} $domain -> $cname -> $final (NO A RECORD)"
  else
    # NOT VULN, ALWAYS OK EVEN IF SAAS/GITHUB/CLOUDFRONT
    echo -e "${GREEN}[OK]${NC} $domain -> $cname -> $final -> $a"
  fi
}

export -f check
export GREEN YELLOW RED BLUE NC

cat hosts | xargs -P 30 -I {} bash -c 'check "{}"'
```

```bash
cat hosts | ./takeover-check.sh
```



## 10. NXDOMAIN Strict Validation

```bash
# Bedain NXDOMAIN beneran vs NODATA sementara
cat potential.txt | while read domain; do
  nxcheck=$(dig "$domain" 2>&1 | grep -i "NXDOMAIN")
  nodata=$(dig +short "$domain" 2>&1)

  if [ -n "$nxcheck" ]; then
    echo "[NXDOMAIN - HIGH] $domain"
  elif [ -z "$nodata" ]; then
    echo "[NODATA - MEDIUM] $domain"
  fi
done
```



## 11. HTTP Body Fingerprinting (False Positive Killer)

```bash
# Verifikasi response body untuk konfirmasi takeover
cat potential.txt | httpx -silent -mc 404,200,400 \
  -ms "There isn't a GitHub Pages site here" \
  -o confirmed-github.txt

cat potential.txt | httpx -silent \
  -ms "NoSuchBucket" \
  -o confirmed-s3.txt

cat potential.txt | httpx -silent \
  -ms "No such app" \
  -o confirmed-heroku.txt
```

### Fingerprint Per Provider

| Provider     | HTTP Fingerprint                             |
| ------------ | -------------------------------------------- |
| GitHub Pages | `There isn't a GitHub Pages site here`       |
| AWS S3       | `NoSuchBucket`                               |
| Heroku       | `No such app`                                |
| Netlify      | `Not Found - Request ID`                     |
| Fastly       | `Fastly error: unknown domain`               |
| Azure        | `404 Web Site not found`                     |
| Shopify      | `Sorry, this shop is currently unavailable`  |
| Zendesk      | `Help Center Closed`                         |
| Surge.sh     | `project not found`                          |
| Readme.io    | `There is no published page here`            |
| Freshdesk    | `May be this is still fresh!`                |
| HelpJuice    | `We could not find what you're looking for`  |
| Webflow      | `The page you are looking for doesn't exist` |



## 12. Automated Tools

### Subzy

```bash
subzy run --targets hosts --concurrency 100 --hide_fails --verify_ssl
```

### Nuclei

```bash
nuclei -t ~/nuclei-templates/dns/ -l hosts
```

```bash
nuclei -t ~/nuclei-templates/http/takeovers/ -l hosts
```

```bash
# Jalanin dengan severity filter
nuclei -t ~/nuclei-templates/http/takeovers/ \
       -t ~/nuclei-templates/dns/ \
       -l hosts \
       -severity medium,high,critical \
       -o nuclei-results.txt
```



## 13. Monitoring Berkala

```bash
# Simpan hasil scan sebelumnya
cp hosts hosts.old

# Jalanin ulang enumeration & validasi
# Bandingkan untuk temukan target baru
diff hosts.old hosts | grep "^>" | anew new-targets.txt
```



## Urutan Tahap Lengkap

```
1.  Passive Recon       → subfinder, assetfinder, crt.sh, chaos, github-subdomains, amass
2.  Active Bruteforce   → puredns + alterx
3.  Live Validation     → httpx
4.  DNS Recon           → dnsrecon
5.  CNAME Enumeration   → dig, dnsx
6.  NS Takeover Check   → dig NS
7.  Provider Fingerprint → grep pattern pada domains & cname.txt
8.  Takeover Check      → takeover-check.sh (dig based)
9.  NXDOMAIN Validation → strict dig check
10. HTTP Fingerprinting → httpx -ms (PALING PENTING, kurangi false positive)
11. Automated Scan      → subzy + nuclei
12. Manual Verification → konfirmasi manual tiap finding
13. PoC & Report        → dokumentasi + bukti
```