# fff


The Fairly Fast Fetcherr / Pengambil Data yang Cukup Cepat. Meminta sejumlah URL yang diberikan melalui stdin dengan cukup cepat.

Ide utamanya adalah meluncurkan permintaan baru setiap nmilidetik, tanpa menunggu agar permintaan terakhir selesai lebih dulu. Hal ini menghasilkan pengambilan data yang konsisten dan cepat. Namun, hal ini dapat membebani sumber daya sistem (misalnya, Anda mungkin kehabisan deskriptor file). Namun keuntungannya adalah, mengakses banyak URL yang sangat lambat atau URL yang Terjadinya time-out tidak terlalu memperlambat kemajuan secara keseluruhan. 


## INPUT PREPARATION (WAJIB)

```bash 
cat hosts | fff -d 1 -S -o roots
```


**Tujuan :**
  - kumpulkan response mentah (offline dataset)
  - mapping endpoint behavior
  - analisis full surface tanpa live request lagi

Output:

* `roots/`


## FILE STRUCTURE DISCOVERY (POST-COLLECTION)

```bash id="s5"
# Cari semua body response
find . -type f -name "*.body"

# Cari metadata request/response
find . -type f -name "*.meta"

# Cari response headers
find . -type f -name "*.headers"

# Cari file redirect-related
find . -type f -name "*redirect*"

# Cari redirect chain
find . -type f -name "*chain*"
```

**Tujuan :**
  * memahami struktur hasil crawl FFF
  * pisahkan data berdasarkan tipe response
  * identifikasi flow request → response → redirect
  * mapping hasil crawl dari `fff`
  * tahu file mana yang perlu dianalisis:
    * body
    * headers
    * redirects
    * chains

Biasanya dipakai sebelum grep analysis berikutnya.

## RESPONSE CONTENT ANALYSIS (CORE PHASE)

### Error / Debug Disclosure

```bash id="s17"
grep -Rni "error\|exception\|stack\|failed\|traceback" roots/

# atau 
gf debug-pages
```

**Tujuan :**
  - stack trace leakage
  - debug mode exposure
  - backend framework disclosure


### Sensitive Data Leak Hunting

```bash
grep -RniE "token|key|secret|jwt|authorization|bearer|apikey|session" roots/
grep -Rni "set-cookie\|session\|auth" roots/
grep -Rni "userId\|sub\|uid\|accountId" roots/
grep -Rni "user\|account\|profile\|order\|payment" roots/
```

**Tujuan :**
  - credential leakage
  - auth token exposure
  - API key leak di response

### API / Endpoint Behavior Mapping

```bash
find roots -name "*.body"
```
Lanjutkan denga :

```bash
grep -RniE "/api/|graphql|/v[0-9]|/auth|/user|/admin" roots/
grep -Rni "api\|auth\|token\|graphql\|user\|id=" roots/
```

**Tujuan :**
  - mapping real API behavior
  - menemukan hidden endpoint dari response
  - memahami response structure (JSON schema)


### Body Processing

```bash
find . -type f -name "*.body" | html-tool tags title 
```

**Tujuan :**
  * overview cepat isi hasil crawling
  * lihat titles/pages tanpa buka satu-satu

**Useful untuk :**
- * login pages
- * dashboards
- * error pages
- * admin panels
- * docs pages

## AUTH / ACCESS CONTROL SURFACE

```bash
grep -RniE "role|permission|admin|access|priv|auth" roots/
```

**Tujuan :**
  - IDOR hints
  - privilege escalation surface
  - role-based logic leakage

## JSON / API STRUCTURE ANALYSIS

```bash
grep -RhoE "\{.*\}" roots/*.body | head
```

Atau :

```bash
jq . roots/**/*.body 2>/dev/null
```

**Tujuan :**
  - detect hidden fields (userId, role, price, status)
  - identify IDOR parameters
  - map API schema

## PERFORMANCE / BEHAVIOR INSIGHT

```bash
grep -Rni "timeout\|rate limit\|too many requests\|429" roots/
```

**Tujuan :**
  - rate limit behavior
  - anti-bot logic detection
  - brute-force feasibility


## FINAL RECON OUTPUT SUMMARY

**Dari FFF pipeline ini kamu harus bisa dapat :**
  - semua response body offline
  - semua header behavior
  - error leakage
  - hidden API endpoints
  - auth/role structure
  - parameter candidates
  - redirect chains
  - JSON schema exposure