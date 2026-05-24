# 📌 Parameter Extraction & Analysis

Dari hasil crawling sebelumnya (Katana / Wayback / crawling manual), kita lanjut ke tahap **extract endpoint yang mengandung parameter** untuk kebutuhan testing lebih lanjut.


## 📥 1. Filter URL yang mengandung parameter

```bash
# Ambil URL yang punya query parameter (?id=, ?user=, dll)
cat urls | grep "=" > params.txt
```



## 📌 2. Extract nama parameter saja (keys)

```bash
# Contoh output: id, user, token, redirect
cat urls | grep -oP '[?&]\K[^=]+' | sort -u
```


## 📌 3. Extract parameter + value (key=value)

```bash
# Contoh output: id=1, user=admin
cat urls | grep -oP '[?&][^&]+' | sort -u
```


## 📌 4. Deep parameter parsing (lebih lengkap)

```bash
# Extract keys
cat urls | unfurl -u keys | sort -u

# Extract values
cat urls | unfurl -u values | sort -u

# Extract key=value pairs
cat urls | unfurl -u keypairs | sort -u

# Extract path
cat urls | unfurl -u paths

# Extract domain
cat urls | unfurl -u domains

# Extract query string full
cat urls | unfurl -u query
```


## 🎯 Tujuan tahap ini

Mapping semua parameter yang ada di target untuk menemukan input yang bisa diuji:

* XSS
* Open Redirect
* SSRF
* IDOR
* Parameter Pollution
* Authentication bypass
* Business logic flaws


## 🔥 Output penting

```
params.txt
```

Berisi semua URL yang punya parameter untuk:

* fuzzing
* manual testing
* automation (gf / ffuf / qsreplace)


## 📌 Insight penting

Parameter yang paling sering menarik:

* `id`
* `user`
* `redirect`
* `url`
* `next`
* `return`
* `file`
* `token`
* `callback`


## ✔️ Kesimpulan flow

```
Crawling (katana/wayback)
        ↓
Extract URLs
        ↓
Filter parameter URLs
        ↓
Extract keys & values
        ↓
Identify attack surface
        ↓
Fuzzing / manual testing
```

