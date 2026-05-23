# 🔍 2 - Endpoint, Secret, & API Mining

Analisis file JS untuk menemukan endpoint tersembunyi, kebocoran secret, dan API internal.

---

## 🎯 Endpoint Mining

### Dari live JS URLs (STATIC - FAST)

```bash
subjs -i js/live-js | sort -u > js/endpoints_subjs.txt
```

### DYNAMIC crawl (DEEP)

```bash
katana -list js/live-js -js-crawl -silent -o js/endpoints_katana.txt
```

### Pakai Linkfinder

```bash
python3 linkfinder.py -i js/live-js -o cli
```

### Bulk - membaca semua URL JS dengan Linkfinder

```bash
cat js/live-js | xargs -I{} python3 linkfinder.py -i {} -o cli | sort -u
```

### Raw grep untuk endpoint

```bash
grep -R -Eo '(https?://[^"'\'' ]+|/api/[^"'\'' ]+|graphql|/occ/|/v[0-9]/)' js/ | sort -u
```

```bash
grep -rhoE "(api|/v[0-9]|/graphql|/rest|/ajax)[^\"' )]+" . | sort -u
```

```bash
grep -rhoE "https?://[^\"' )]+|/(v[0-9]+|api|graphql|rest|ajax)[^\"' )]*" js/
```

---

## 📊 Merge + Deduplicate endpoints

```bash
cat js/endpoints_subjs.txt js/endpoints_katana.txt | sort -u > js/endpoints_raw.txt
```

---

## 🧹 Normalize API surface

```bash
grep -Eo "(https?://[^ ]+|/api/[^ ]+|/v[0-9]+/[^ ]+|graphql|rest|ajax)" js/endpoints_raw.txt | sort -u > js/endpoints_clean.txt
```

---

## 🎯 Filter yang benar-benar attackable

```bash
cat js/endpoints_clean.txt | grep -Ei "api|auth|admin|user|token|graphql|v1|v2"
```

---

## 🔥 Cari endpoint API (PALING PRIORITAS)

```bash
grep -RniE "/api/|/ws/|/v1/|/v2/|/rhe/" file.js
```

```bash
cat file.js | grep -RohE '(https?:\/\/|\/api\/|\/v1\/|\/v2\/|\/graphql\/)[^"'\'' ]+'
```

```bash
grep -Rni "/api\|/v1\|/v2\|/internal\|/admin\|/test\|/debug" swagger-ui-beautifier.js
```

### Cari host backend

```bash
grep -Rni "https://\|http://" swagger-ui-beautifier.js
```

**Target kamu:**
- hidden endpoint
- internal service
- admin API

---

## 🔥 Cari endpoint construction dynamic (HIGH VALUE)

```bash
grep -RniE "\+.*api|fetch\(|axios|XMLHttpRequest|$.ajax" file.js
```

**Tujuan:**
- lihat bagaimana request dibentuk
- kadang ada parameter injection point

---

## 🔥 Cari auth / token / session

```bash
grep -RniE "token|jwt|authorization|auth|session|cookie|bearer" file.js
```

**Yang dicari:**
- hardcoded token
- header injection logic
- session handling leak

---

## 🔥 Cari secret / credential leakage

```bash
grep -RniE "secret|key|apikey|api_key|client_secret|password|private" file.js
```

```bash
grep -Rni "key\|token\|secret\|apikey\|auth" swagger-ui-beautifier.js
```

**Biasanya muncul:**
- API key frontend leak
- OAuth client secret (kadang fatal bug)
- third-party service key

---

## 🔥 Cari config / env leak

```bash
grep -RniE "config|env|process.env|window.__|__CONFIG__|settings" file.js
```

**Ini sering ketemu:**
- backend URL hidden
- internal staging endpoint
- feature flag bypass

---

## 🔥 Cari OpenAPI / Swagger reference

```bash
grep -RniE "swagger|openapi|api-doc|json|yaml" file.js
```

**Kadang ada:**
- hidden swagger endpoint
- internal API schema
- dev endpoint

---

## 🔥 Cari hidden feature / debug / dev mode

```bash
grep -RniE "debug|test|mock|staging|dev|internal" file.js
```

---

## 🔥 Cari Request builder

```bash
grep -Rni "fetch\|axios\|XMLHttpRequest\|ajax\|request" swagger-ui-beautifier.js
```

---

## 📧 Email Hunting

```bash
cat js/*.js | grep -Eio '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}' | sort -u
```

Atau recursive:

```bash
find . -type f -name '*.js' -exec cat {} \; | \
grep -Eio '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}' | \
sort -u
```

---

## 🔑 Secret extraction dengan tools tambahan

### jsleak

```bash
cat js/live-js | jsleak -s -l -k
```

### Nuclei

```bash
cat js/live-js | nuclei -t ~/nuclei-templates/http/exposures -c 30
```

### Trufflehog

```bash
cat live-js | while read url; do
  curl -s "$url" | sudo trufflehog stdin --no-update
done
```

---

## 💣 PRO TIP (ini yang biasanya bikin ketemu bug)

Jangan cuma grep → kombinasi:

### Step lanjut:

```bash
strings file.js | sort | uniq | grep -i api
```

Atau:

```bash
cat file.js | jq (kalau JSON besar)
```

---

## 🧹 Extract Interesting Indicators

```bash
grep -Er 'api|token|key|debug|auth|secret|flag|admin' beautified/ > indicators.txt
```

```bash
grep -Er 'fetch\(|axios|XMLHttpRequest' beautified/ > apis.txt
```

```bash
# Periksa juga string Base64, kunci API, atau kebocoran skema GraphQL:
grep -E '[A-Za-z0-9+/]{40,}' beautified/
```

---

## 🗺 Mapping JS logic

```bash
grep -RniE "fetch|axios|XMLHttpRequest|ajax" js/live-js
```

Atau:

```bash
grep -RniE "api|baseURL|endpoint|url|host" js/live-js
```

---

## 🔍 CORS / auth behavior check

```bash
curl -i https://target/api/endpoint
curl -i https://target/api/endpoint -H "Origin: https://evil.com"
```

---

## 📍 Missing: sourcemap detection (.map)

```bash
cat js/live-js | grep '\.map'
```
