# 📘 PARAMETER DISCOVERY HANDBOOK (BUG BOUNTY)


# 1. 🔍 INPUT SOURCES (WAJIB)

## 🔹 [URL collection](https://1amkaiz3ns-books.gitbook.io/bug-bounty/methodology/recon/urls-crawling)




# 2. 🧹 BASIC PARAMETER EXTRACTION

## 🔹 From URLs (simple)

```bash
cat urls | grep "=" > params_raw.txt
```

## 🔹 Clean keys only (recommended)

```bash
cat urls | unfurl keys | sort -u > params.txt
```

## 🔹 Clean key=value pairs

```bash
cat urls | qsreplace -a | sort -u > params_kv.txt
```

# 3. 🎯 FILTER HIGH VALUE PARAMETERS

```bash
cat params.txt | grep -Ei \
"id|uid|user|account|email|role|token|auth|session|key|file|path|redirect|url|next|callback|return|page|limit|offset|sort|filter" \
> params_highvalue.txt
```


# 4. ⚡ GF PATTERN (SELECTIVE ONLY)

## 🔹 IDOR

```bash
cat urls | gf idor > gf_idor.txt
```

## 🔹 Open Redirect

```bash
cat urls | gf redirect > gf_redirect.txt
```

## 🔹 SSRF

```bash
cat urls | gf ssrf > gf_ssrf.txt
```

## 🔹 XSS

```bash
cat urls | gf xss > gf_xss.txt
```

# 5. 🧠 ARJUN (PARAM DISCOVERY ENGINE)

## 🔹 Basic

```bash
arjun -i urls.txt -oT arjun_params.txt
```

## 🔹 GET only (faster)

```bash
arjun -i urls.txt --get -oT arjun_get.txt
```

## 🔹 Full (GET + POST + Headers)

```bash
arjun -i urls.txt --get --post --headers -oT arjun_full.txt
```



# 6. ⚙️ JS PARAM MINING

## 🔹 from JS files

```bash
cat urls | grep ".js" | httpx -silent | hakrawler -d 2
```

## 🔹 extract params from JS

```bash
cat js.txt | grep -Eo "[a-zA-Z0-9_]{2,}=" | sort -u
```



# 7. 🔥 COMBINED ADVANCED FLOW

```bash
# 1. Collect URLs
katana + gau + wayback + hakrawler → urls.txt

# 2. Extract params
unfurl keys → params.txt

# 3. Filter high value
grep id/user/token → params_high.txt

# 4. Run arjun
arjun -i urls.txt → arjun.txt

# 5. GF patterns
gf idor/redirect/ssrf → gf.txt

# 6. Merge all
cat params_high.txt arjun.txt gf.txt | sort -u > final_params.txt
```



# 8. 💣 PRIORITY PARAMETER TARGETS

## 🔥 HIGH IMPACT

```
id
user_id
account_id
email
role
token
session
auth
key
```

## 🔥 FLOW CONTROL (sering bug logic)

```
redirect
next
return
url
callback
continue
```

## 🔥 DATA ACCESS

```
file
path
document
download
export
view
```

# 9. ❌ COMMON MISTAKE

* pakai GF full set → noise
* arjun di semua URL → lambat
* gak filter API dulu → buang waktu
* testing static assets → useless

# 10. ✔️ REAL BUG BOUNTY PIPELINE

```text
RECON
  ↓
URL collection (katana/gau/wayback)
  ↓
filter API endpoints
  ↓
parameter extraction (unfurl)
  ↓
arjun expansion
  ↓
gf selective patterns
  ↓
merge
  ↓
urls test (httpx + curl)
  ↓
manual exploit
```
