
# PARAMETER EXTRACTION & ANALYSIS HANDBOOK

## PART 1: INPUT SOURCES (URL COLLECTION)

```bash
# Sources for URL collection:
# - Katana
# - Wayback Machine
# - GAU (Get All URLs)
# - Hakrawler
# - Manual crawling
```

#` PART 2: BASIC PARAMETER EXTRACTION

```bash
# 2.1 Filter URL yang mengandung parameter
cat urls | grep "=" > params.txt

# 2.2 Extract nama parameter saja (keys)
cat urls | grep -oP '[?&]\K[^=]+' | sort -u > params_keys.txt

# 2.3 Extract parameter + value (key=value pairs)
cat urls | grep -oP '[?&][^&]+' | sort -u > params_kv.txt

# 2.4 Clean keys using unfurl (recommended)
cat urls | unfurl keys | sort -u > params.txt

# 2.5 Clean key=value pairs using qsreplace
cat urls | qsreplace -a | sort -u > params_kv_clean.txt
```

## PART 3: DEEP PARAMETER PARSING WITH UNFURL

```bash
cat urls | unfurl -u keys | sort -u        # Extract keys
cat urls | unfurl -u values | sort -u      # Extract values
cat urls | unfurl -u keypairs | sort -u    # Extract key=value pairs
cat urls | unfurl -u paths | sort -u       # Extract paths
cat urls | unfurl -u domains | sort -u     # Extract domains
cat urls | unfurl -u query | sort -u       # Extract full query strings
```

## PART 4: FILTER HIGH VALUE PARAMETERS

```bash
cat params.txt | grep -Ei \
"id|uid|user|account|email|role|token|auth|session|key|file|path|redirect|url|next|callback|return|page|limit|offset|sort|filter" \
> params_highvalue.txt
```

## PART 5: GF PATTERNS (SELECTIVE)

```bash
cat urls | gf idor > gf_idor.txt           # IDOR patterns
cat urls | gf redirect > gf_redirect.txt   # Open Redirect patterns
cat urls | gf ssrf > gf_ssrf.txt           # SSRF patterns
cat urls | gf xss > gf_xss.txt             # XSS patterns
cat urls | gf sqli > gf_sqli.txt           # SQL Injection patterns
cat urls | gf lfi > gf_lfi.txt             # LFI patterns
cat urls | gf rce > gf_rce.txt             # RCE patterns
```

## PART 6: ARJUN (PARAM DISCOVERY ENGINE)

```bash
# 6.1 Basic arjun scan
arjun -i urls.txt -oT arjun_params.txt
```

```bash
# 6.2 GET only (faster)
arjun -i urls.txt --get -oT arjun_get.txt
```

```bash
# 6.3 Full scan (GET + POST + Headers)
arjun -i urls.txt --get --post --headers -oT arjun_full.txt
```

```bash
# 6.4 With custom wordlist
arjun -i urls.txt -w /path/to/wordlist.txt -oT arjun_custom.txt
```

## PART 7: JS PARAM MINING

```bash
# 7.1 Extract JS files from URLs
cat urls | grep "\.js" | httpx -silent > js_files.txt

# 7.2 Crawl JS files for additional endpoints
cat js_files.txt | hakrawler -d 2 > js_endpoints.txt

# 7.3 Extract parameters from JS files
cat js_files.txt | grep -Eo "[a-zA-Z0-9_]{2,}=" | sort -u > js_params.txt

# 7.4 Extract from raw JS content
cat js_files.txt | while read js; do curl -s "$js" | grep -Eo "[a-zA-Z0-9_]{2,}="; done | sort -u
```

## PART 8: COMBINED ADVANCED FLOW

```bash
# Step-by-step complete pipeline:

# 1. Collect URLs (multiple sources)
katana -u target.com -o katana.txt
gau target.com > gau.txt
waybackurls target.com > wayback.txt
hakrawler -url target.com -d 3 > hakrawler.txt

# 2. Merge and sort unique URLs
cat katana.txt gau.txt wayback.txt hakrawler.txt | sort -u > all_urls.txt

# 3. Extract params
unfurl keys < all_urls.txt | sort -u > params.txt

# 4. Filter high value
grep -E "id|user|token|redirect|url|file" params.txt > params_high.txt

# 5. Run arjun on live hosts
httpx -l all_urls.txt -silent -o live_urls.txt
arjun -i live_urls.txt -oT arjun_discovered.txt

# 6. GF patterns on all URLs
gf idor < all_urls.txt > gf_idor.txt
gf redirect < all_urls.txt > gf_redirect.txt

# 7. Merge all discoveries
cat params_high.txt arjun_discovered.txt gf_idor.txt gf_redirect.txt | sort -u > final_params.txt
```

```bash
# Single command merged pipeline:
cat urls.txt | unfurl keys | sort -u > params.txt && \
grep -Ei "id|uid|user|account|email|role|token|auth|session|key|file|path|redirect|url|next|callback|return" params.txt > params_high.txt && \
arjun -i urls.txt --get -oT arjun_new.txt && \
cat params_high.txt arjun_new.txt | sort -u > all_discovered_params.txt
```

## PART 9: PRIORITY PARAMETER TARGETS


```bash
# 🔥 HIGH IMPACT (Authentication & Authorization)
id, user_id, account_id, uid, email, role, token, session, auth, key, apikey

# 🔥 FLOW CONTROL (Business Logic Bugs)
redirect, next, return, url, callback, continue, goto, forward

# 🔥 DATA ACCESS (Information Disclosure)
file, path, document, download, export, view, read, get, show

# 🔥 INPUT PROCESSING (Injection Vectors)
q, query, search, s, keyword, term, filter, order, sort

# 🔥 FUNCTIONAL (Feature-specific)
page, limit, offset, start, end, from, to, date
```


## PART 10: VULNERABILITY TESTING GUIDE


```bash
# XSS Testing
# Parameters: q, search, query, s, keyword, term, callback, return

# Open Redirect Testing
# Parameters: redirect, next, return, url, callback, continue, goto, forward

# SSRF Testing
# Parameters: url, uri, path, dest, redirect, return, next, view, load

# IDOR Testing
# Parameters: id, user_id, account_id, uid, email, document_id, file_id

# SQL Injection Testing
# Parameters: id, cat, category, page, sort, order, filter, search

# LFI/RFI Testing
# Parameters: file, path, document, page, view, include, require

# Parameter Pollution Testing
# Any parameter that appears multiple times in the same request
```


## PART 11: REAL BUG BOUNTY PIPELINE


```bash
COMPLETE PIPELINE:

RECON
  ├── Subdomain enumeration
  ├── Port scanning
  └── Technology detection
      ↓
URL COLLECTION
  ├── Katana (active crawling)
  ├── GAU (historical URLs)
  ├── Wayback Machine
  ├── Hakrawler (JS crawling)
  └── Manual exploration
      ↓
FILTER & NORMALIZE
  ├── Remove duplicates
  ├── Filter API endpoints
  ├── Remove static assets (.css,.js,.png,.jpg)
  └── Keep only parameter URLs
      ↓
PARAMETER EXTRACTION
  ├── unfurl keys (basic)
  ├── unfurl keypairs (detailed)
  └── Filter high-value params
      ↓
PARAMETER DISCOVERY
  ├── Arjun (hidden parameters)
  ├── ParamSpider
  └── Custom wordlists
      ↓
PATTERN MATCHING
  ├── GF (idor, redirect, ssrf, xss)
  ├── Custom regex patterns
  └── Manual review
      ↓
TESTING
  ├── httpx (live hosts only)
  ├── qsreplace (param manipulation)
  ├── ffuf (fuzzing)
  └── Manual exploitation
      ↓
REPORTING
  ├── Validate findings
  ├── Create PoC
  └── Submit bug report
```


## PART 12: QUICK COMMAND REFERENCE

```bash
# Extract URLs with parameters
cat urls | grep "=" > param_urls.txt

# Get unique parameter names
grep -oP '(?<=[?&])[^=]+' urls.txt | sort -u

# Get all parameter instances
grep -oP '(?<=[?&])[^&]+' urls.txt | sort -u

# Count parameter frequency
grep -oP '(?<=[?&])[^=]+' urls.txt | sort | uniq -c | sort -rn

# Extract specific parameter values
grep -oP 'id=\K[^&]*' urls.txt | sort -u

# Test single parameter across all URLs (with qsreplace)
cat urls.txt | qsreplace 'PAYLOAD' | httpx -silent

# Batch replace parameter values
sed -E 's/(id=)[^&]*/\1TESTVALUE/g' urls.txt
```

## PART 13: COMMON MISTAKES TO AVOID


```bash
❌ Using full GF pattern set → produces too much noise
❌ Running arjun on all URLs without filtering → very slow
❌ Not filtering API endpoints first → wastes time
❌ Testing static assets (.css, .js, .jpg) → useless
❌ Ignoring POST parameters → missing critical attack surface
❌ Not validating if URLs are alive before testing → waste of resources
❌ Testing parameters without understanding context → low efficiency

✅ ALWAYS:
  1. Filter live hosts first (httpx)
  2. Remove static file extensions
  3. Prioritize API endpoints
  4. Test high-value parameters first
  5. Combine automated + manual testing
```


## PART 14: OUTPUT FILES SUMMARY

OUTPUT FILES:
  - params.txt          - All URLs containing parameters
  - params.txt              - Unique parameter names
  - params_kv.txt           - Unique key=value pairs
  - params_highvalue.txt    - Priority parameters only
  - gf_idor.txt             - URLs with IDOR potential
  - gf_redirect.txt         - URLs with redirect parameters
  - gf_ssrf.txt             - URLs with SSRF potential
  - gf_xss.txt              - URLs with XSS potential
  - arjun_params.txt        - Newly discovered parameters
  - final_params.txt        - Complete parameter list

