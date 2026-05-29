# CORS

## API endpoints Mining

Kumpulkan semau API Endpoints dari urls.txt hasil crawl katana,wayback,dll
```bash
echo "📡 Finding API endpoints..."
cat urls.txt | \
  grep -iE "/api/|/v1/|/v2/" | \
  cut -d'?' -f1 | \
  grep -vE "\.js|\.css|\.png|\.jpg|\.jpeg|\.svg|\.gif|\.woff|\.ttf|\.html|/v1/[a-zA-Z]{1,3}$|/v1/$" | \
  grep -vE "/v1/ar|/v1/en|/v1/fr|/v1/[a-z]{2}(-[a-z]{2})?$" | \
  uro | sort -u > api_endpoints.txt
```

## Live endpoints

Filter live urls

```bash
cat api_endpoints.txt 2>/dev/null | \
  sort -u | \
  httpx -silent -mc 200 -follow-redirects -timeout 10 -threads 50 > live_apis.txt

echo "✅ Live: $(wc -l < live_apis.txt 2>/dev/null || echo 0)"
```

## CORS check karo

```bash
echo "🔍 Checking CORS (UPGRADED)..."

while read url; do

  for origin in \
    "https://evil.com" \
    "https://target.com.evil.com" \
    "null"
  do

    response=$(curl -s -i \
      -H "Origin: $origin" \
      -H "Cookie: test=test" \
      "$url" 2>/dev/null)

    acao=$(echo "$response" | grep -i "access-control-allow-origin" | head -1)
    acac=$(echo "$response" | grep -i "access-control-allow-credentials" | head -1)

    # detect wildcard / reflection / null bypass
    if echo "$acao" | grep -Eqi "$origin|\\*|null|evil"; then

      if echo "$acac" | grep -qi "true"; then

        echo "🔴 CRITICAL CORS: $url ($origin)" >> cors_vulnerable.txt
        echo "$acao" >> cors_vulnerable.txt
        echo "$acac" >> cors_vulnerable.txt
        echo "----" >> cors_vulnerable.txt

      else

        echo "🟡 CORS (no creds): $url ($origin)" >> cors_partial.txt

      fi
    fi

  done

done < live_apis.txt
```


## cors_hunter.sh (FULL AUTO TOOL)

```bash
#!/bin/bash

TARGET_URLS="urls.txt"
OUTDIR="cors_results"

mkdir -p $OUTDIR

echo "=================================="
echo "🚀 CORS AUTO HUNTER v2 STARTING"
echo "=================================="

#####################################
# STEP 1 - API MINING (clean + stronger)
#####################################
echo "📡 [1/4] Mining API endpoints..."

cat $TARGET_URLS 2>/dev/null | \
  tr -d '\r' | \
  grep -iE "/api/|/v1/|/v2/|/auth|/login|/user|/config|/chat|/track" | \
  cut -d'?' -f1 | \
  grep -vE "\.js|\.css|\.png|\.jpg|\.jpeg|\.svg|\.gif|\.woff|\.ttf|\.html|\.json|\.map" | \
  sort -u > $OUTDIR/api_endpoints.txt

echo "✅ APIs found: $(wc -l < $OUTDIR/api_endpoints.txt 2>/dev/null || echo 0)"

#####################################
# STEP 2 - LIVE CHECK (REALISTIC STATUS)
#####################################
echo "🌐 [2/4] Checking live endpoints..."

cat $OUTDIR/api_endpoints.txt 2>/dev/null | \
  httpx -silent \
    -status-code \
    -title \
    -follow-redirects \
    -timeout 15 \
    -threads 50 > $OUTDIR/live_apis.txt

echo "✅ Live endpoints: $(wc -l < $OUTDIR/live_apis.txt 2>/dev/null || echo 0)"

#####################################
# STEP 3 - CORS FUZZ ENGINE (UPGRADED)
#####################################
echo "🔍 [3/4] CORS testing started..."

rm -f $OUTDIR/cors_vulnerable.txt $OUTDIR/cors_partial.txt

while read url; do

  for origin in \
    "https://evil.com" \
    "https://target.com.evil.com" \
    "null" \
    "https://localhost" \
    "https://evil.com%60target.com"
  do

    response=$(curl -sk -i \
      -H "Origin: $origin" \
      -H "Cookie: test=test" \
      "$url" 2>/dev/null)

    acao=$(echo "$response" | grep -i "access-control-allow-origin" | head -1)
    acac=$(echo "$response" | grep -i "access-control-allow-credentials" | head -1)

    #####################################
    # DETECTION ENGINE (STRONG)
    #####################################
    if echo "$acao" | grep -Eqi "evil|\\*|null|target\\.com|localhost|$origin"; then

      if echo "$acac" | grep -qi "true"; then

        echo "🔴 CRITICAL CORS: $url ($origin)" >> $OUTDIR/cors_vulnerable.txt
        echo "$acao" >> $OUTDIR/cors_vulnerable.txt
        echo "$acac" >> $OUTDIR/cors_vulnerable.txt
        echo "-----" >> $OUTDIR/cors_vulnerable.txt

      else

        echo "🟡 INFO CORS: $url ($origin)" >> $OUTDIR/cors_partial.txt

      fi
    fi

  done

done < $OUTDIR/live_apis.txt

#####################################
# STEP 4 - INTELLIGENT REPORT
#####################################
echo "=================================="
echo "📊 CORS HUNT COMPLETE"
echo "=================================="

echo "API Endpoints   : $(wc -l < $OUTDIR/api_endpoints.txt 2>/dev/null || echo 0)"
echo "Live APIs       : $(wc -l < $OUTDIR/live_apis.txt 2>/dev/null || echo 0)"
echo "Critical CORS   : $(wc -l < $OUTDIR/cors_vulnerable.txt 2>/dev/null || echo 0)"
echo "Partial CORS    : $(wc -l < $OUTDIR/cors_partial.txt 2>/dev/null || echo 0)"

echo "=================================="
echo "📁 Output: $OUTDIR/"
echo "=================================="
```