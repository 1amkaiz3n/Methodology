# 403 BYPASS ATTACK PHASE



## 1. METHOD BYPASS TESTING

**Tujuan :**
  * cari endpoint yang:
    * GET = 403
    * tapi:
      * OPTIONS = 200
      * HEAD = 200
      * POST = 200


Itu valid finding candidate.



### Command

**cek variasi response :**

```bash
for m in GET POST OPTIONS HEAD; do httpx -l ../403-Bypass/targets.txt -x $m -status-code -content-length -silent | sed "s/$/ [$m]/"; done
```

Atau :

```bash
for m in GET POST PUT PATCH OPTIONS HEAD TRACE; do
  httpx -l ../403-Bypass/targets.txt \
  -x $m \
  -status-code \
  -content-length \
  -title \
  -silent \
  | sed "s/$/ [$m]/"
done | tee ../403-Bypass/method_bypass.txt
```

## Tools 403 Bypass

```bash
./bypass-403.sh https://example.com/admin
```

## 2. HEADER BYPASS TESTING

Classic 403 bypass layer.

Cari:

* reverse proxy trust issue
* internal IP bypass
* host confusion



### Header candidates

```text
X-Forwarded-For: 127.0.0.1
X-Originating-IP: 127.0.0.1
X-Remote-IP: 127.0.0.1
X-Client-IP: 127.0.0.1
X-Forwarded-Host: localhost
```



### Tools

Pake:

* ffuf
* curl
* nuclei custom templates
* burp intruder



### Contoh

```bash
ffuf -w ../403-Bypass/targets.txt:HOST -u https://HOST/ -H "X-Forwarded-For: 127.0.0.1"
```



## 3. PATH NORMALIZATION BYPASS

Cari:

* proxy/backend mismatch
* path confusion



### Payload examples

```text
/admin
//admin
/%2e/admin
/admin/.
;/admin
..;/
%2e%2e/
```



## 4. CDN / ORIGIN DISCOVERY

Ini penting banget.

Karena lu udah nemu:

* Cloudflare
* CloudFront
* Azure
* TrafficManager

Tujuannya:

* cari IP origin asli
* bypass CDN/WAF



### Cari:

* direct IP
* leaked hostname
* alternate subdomain
* old DNS
* exposed origin



### Tools

* dnsx
* httpx
* censys
* shodan
* securitytrails
* uncover
* nuclei ssl



## 5. HOST HEADER FUZZING

Cari:

* virtual host confusion
* hidden backend



### Contoh

```bash
ffuf -w wordlist.txt \
-u https://TARGET/ \
-H "Host: FUZZ"
```



## 6. CACHE BEHAVIOR TESTING

Karena banyak Cloudflare.

Cari:

* cache poisoning
* cache deception
* stale cache leak



### Cek:

```text
cf-cache-status
x-cache
age
via
```



## 7. RESPONSE DIFFERENTIAL ANALYSIS

Ini advanced dan powerful.

Bandingin:

* GET
* POST
* OPTIONS
* HEAD

Lihat:

* size beda
* title beda
* redirect beda
* latency beda

Kadang:

```text
403 GET
200 OPTIONS
404 HEAD
302 POST
```

itu tanda backend leak.



## 8. PARAMETER DISCOVERY

403 kadang cuma di root.

Tapi:

```text
/api/
/v1/
/swagger
/graphql
/internal
/debug
```

ternyata open.



### Pakai:

```bash
ffuf
dirsearch
feroxbuster
katana
hakrawler
```



## 9. JAVASCRIPT RECON

Penting banget buat target modern.

Cari:

* hidden API
* leaked endpoints
* admin panel
* internal URL



### Tools

* katana
* hakrawler
* gau
* waybackurls
* secretfinder



## 10. AUTOMATED NUCLEI PASSIVE

Baru setelah recon matang.



### Jalankan:

```bash
nuclei -l targets.txt -severity low,medium,high,critical
```

atau:

```bash
nuclei -tags exposure,misconfig,cloud,auth
```
