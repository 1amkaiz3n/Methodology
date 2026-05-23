# HTTPX Only — Methodology Recon & Fingerprinting

Flow khusus `httpx` doang buat:

* live host
* fingerprinting
* clustering
* prioritization
* hunting anomaly

---

# 1. Alive Check

## Basic

**Multi target**

```bash
cat domains| httpx \
  -silent \
  -threads 200 \
  -timeout 10 \
  -retries 1 \
  -follow-redirects \
  -o hosts
```

**Single target**

```bash
httpx -u uat-uae.onevasco.com
```

---

# Fingerprinting

## 1.

```bash
httpx -u uat-uae.onevasco.com \
  -silent \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -ip \
  -cname \
  -location
```

Output :
```bash
https://uat-uae.onevasco.com [403] [] [520] [403 Forbidden] [awselb/2.0] [18.130.147.54] [uat-ffa-1233947905.eu-west-2.elb.amazonaws.com] [Amazon ELB,Amazon Web Services]
```

## 2. Infra

```bash
httpx -u uat-uae.onevasco.com \
  -silent \
  -threads 200 \
  -timeout 8 \
  -retries 1 \
  -ip \
  -asn \
  -cdn \
  -cname \
  -jarm \
  -http2 \
  -pipeline \
  -tls-probe \
  -tls-grab \
  -vhost \
  -websocket \
  -json | jq
```

**Apa Yang Didapat :**
  - IP
  - ASN
  - CDN/WAF
  - CNAME
  - TLS
  - JARM
  - HTTP2
  - Pipeline
  - VHOST
  - Websocket


## 3.Web Fingerprint

```bash
httpx -u uat-uae.onevasco.com \
  -silent \
  -threads 200 \
  -timeout 8 \
  -retries 1 \
  -follow-redirects \
  -status-code \
  -title \
  -web-server \
  -tech-detect \
  -content-type \
  -content-length \
  -location \
  -hash md5 \
  -hash mmh3 \
  -hash sha256 \
  -json | jq
```

**Apa Yang Didapat :**
  - title
  - server
  - tech stack
  - content-type
  - content-length
  - hashes
  - status
  - redirect


## 4. Deep Recon

```bash
httpx -u uat-uae.onevasco.com \
  -silent \
  -threads 100 \
  -timeout 10 \
  -follow-redirects \
  -tls-probe \
  -tls-grab \
  -csp-probe \
  -extract-fqdn \
  -include-chain \
  -irr \
  -json | jq
```
**Apa Yang Didapat :**
  - TLS domains
  - CSP domains
  - response chain
  - fqdn extraction
  - raw request/response
- 
##  FULL MAXIMUM HTTPX FINGERPRINT

```bash
httpx -u https://reffbot.aigoretech.cloud \
  -silent \
  -threads 100 \
  -timeout 10 \
  -retries 1 \
  -follow-redirects \
  -status-code \
  -content-length \
  -content-type \
  -location \
  -favicon \
  -hash md5 \
  -hash mmh3 \
  -hash sha256 \
  -jarm \
  -response-time \
  -line-count \
  -word-count \
  -title \
  -web-server \
  -tech-detect \
  -method \
  -websocket \
  -ip \
  -cname \
  -asn \
  -cdn \
  -probe \
  -http2 \
  -pipeline \
  -tls-probe \
  -tls-grab \
  -csp-probe \
  -vhost \
  -extract-fqdn \
  -json \
  -include-chain \
  -irr \
  -store-response \
```








# 3. Human Readable Output

Buat cepat spotting.

```bash
cat hosts | httpx \
  -silent \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -web-server \
  -ip \
  -cdn
```

---

# 4. Status Code Analysis

## 200

```bash
cat hosts | httpx -mc 200
```

---

## 401 / 403

HIGH VALUE.

```bash
cat hosts | httpx \
  -mc 401,403 \
  -title \
  -tech-detect \
  -web-server
```

Cari:

* auth panel
* admin
* internal API
* gateway

---

## 500 / 502 / 503

```bash
cat hosts | httpx \
  -mc 500,502,503
```

Cari:

* broken backend
* proxy issue
* stack trace
* debug

---

# 5. Redirect Mapping

```bash
cat hosts | httpx \
  -follow-redirects \
  -location \
  -status-code
```

Cari:

* SSO
* Keycloak
* login flow
* exposed internal hostname

---

# 6. Tech Stack Clustering

```bash
cat hosts | httpx \
  -tech-detect \
  -silent
```

Cari:

* WordPress
* Keycloak
* Next.js
* Spring
* ASP.NET
* Grafana
* Jenkins

---

# 7. CDN / WAF Detection

```bash
cat hosts | httpx \
  -cdn \
  -web-server \
  -ip
```

Cari:

* Cloudflare
* Akamai
* Azure
* Fastly

NON-CDN biasanya lebih juicy.

---

# 8. IP Reuse Detection

```bash
cat hosts | httpx \
  -ip \
  -silent
```

Cari:

* banyak subdomain → same IP
* kemungkinan same backend

---

# 9. CNAME Analysis

```bash
cat hosts | httpx \
  -cname \
  -silent
```

Cari:

* Azure
* Heroku
* GitHub Pages
* AWS ELB
* dangling CNAME

---

# 10. TLS / Certificate Recon

```bash
cat hosts | httpx \
  -tls-probe \
  -silent
```

Cari:

* SAN leakage
* internal hostname
* forgotten subdomain

---

# 11. JARM Fingerprinting

```bash
cat hosts | httpx \
  -jarm \
  -silent
```

Cari:

* identical infra
* same reverse proxy
* same app family

Kalau JARM sama:

* test vuln sibling target

---

# 12. Favicon Hash Clustering

```bash
cat hosts | httpx \
  -favicon \
  -silent
```

Cari:

* same admin panel
* same SaaS
* duplicate app

---

# 13. Title Clustering

```bash
cat hosts | httpx \
  -title \
  -silent
```

Cari:

* "Sign in"
* "Dashboard"
* "Grafana"
* "Jenkins"
* "Welcome"

---

# 14. Response Size Analysis

```bash
cat hosts | httpx \
  -content-length \
  -silent
```

## Tiny Responses

Cari:

* WAF
* forbidden
* hidden API

## Large Responses

Cari:

* SPA app
* JS-heavy
* dashboard

---

# 15. HTTP/2 & Pipeline Support

```bash
cat hosts | httpx \
  -http2 \
  -pipeline
```

Interesting for:

* request smuggling
* proxy behavior

---

# 16. ASN Mapping

```bash
cat hosts | httpx \
  -asn \
  -silent
```

Cari:

* internal infra
* cloud split
* shadow environments

---

# 17. Probe All Ports

```bash
httpx -l subdomains.txt \
  -ports 80,81,443,3000,5000,7001,7002,8000,8080,8443,9000 \
  -silent
```

Cari:

* Jenkins
* Kibana
* Grafana
* admin panel
* staging

---

# 18. Screenshot Recon

```bash
cat hosts | httpx \
  -ss \
  -system-chrome \
  -silent
```

Buat spotting:

* admin
* debug
* exposed dashboards

---

# 19. Extract Interesting Targets

## Auth Targets

```bash
cat hosts | httpx \
  -title \
  -silent | grep -Ei \
"login|auth|sso|keycloak|signin|account"
```

---

## API Targets

```bash
cat hosts | grep -Ei \
"api|gateway|graphql|backend"
```

---

## Admin Targets

```bash
cat hosts | grep -Ei \
"admin|manage|dashboard|console|staff"
```

---

# 20. Best Priorities After HTTPX

## Tier 1

```txt
401/403 APIs
Keycloak
Swagger
GraphQL
staging/uat/dev
non-CDN assets
weird redirects
```

---

## Tier 2

```txt
WordPress
Next.js
ASP.NET
large SPA
admin panels
```

---

# My Typical HTTPX Flow

```bash
subfinder
↓
httpx alive
↓
httpx fingerprint
↓
status clustering
↓
tech clustering
↓
IP/JARM grouping
↓
prioritize auth/api/admin
↓
deep recon
```
