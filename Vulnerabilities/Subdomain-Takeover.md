# Methodologi Subdomain TakeOver

## 1. Subdomain Enumeration

```bash id="s1"
subfinder -dL wildcards | tee domains

cat wildcard | assetfinder --subs-only | anew domains
```

---

## 2. Live Hosts Validation

```bash id="s2"
cat domains \
| httpx -silent -threads 200 \
| anew hosts
```

---

## 3. DNS Recon

```bash
uvx run dnsrecon -d domin.com
```

---

## 4. CNAME Enumeration & Manual Check

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

---

## 5. CNAME Extraction (Automated)

```bash
cat domains | dnsx -silent -resp-only -cname | tee cname.txt

# atau

cat domains | while read d; do
    dig +short CNAME $d
done
```

---

## 6. Provider Fingerprinting (SaaS Detection)

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

---

## 7. Takeover Check Script (Dig Based)

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
cat hosts  | ~/belajar/bug_bounty/Tools/takeover-check.sh
```

---

## 8. Automated Tools

### Subzy

```bash
subzy run --targets hosts --concurrency 100 --hide_fails --verify_ssl
```

---

### Nuclei

```bash
nuclei -t ~/nuclei-templates/dns/ -l hosts
```

```bash
nuclei -t ~/nuclei-templates/http/takeovers/ -l hosts
```

