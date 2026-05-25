# 🧠 SSRF SECURITY HANDBOOK (Practical Methodology)



## 1. 🔎 RECON STAGE (Menemukan SSRF Endpoint)

### 🎯 Target utama

Cari semua fitur yang bikin server **mengakses URL dari user input**



### 🔥 Pattern endpoint yang wajib dicari

#### A. URL-based input

* `url=`
* `link=`
* `target=`
* `endpoint=`



#### B. Feature yang sering SSRF

* webhook tester
* import image from URL
* link preview
* PDF generator from URL
* file downloader
* AI tool fetch external data
* cron callback URL



### 🧪 Command recon di repo

```bash id="recon1"
grep -R "url" .
grep -R "http" .
grep -R "axios" .
grep -R "fetch" .
grep -R "requests" .
```

atau lebih agresif:

```bash id="recon2"
grep -R "get(" .
grep -R "post(" .
grep -R "curl" .
```



## 2. ⚠️ SSRF SURFACE IDENTIFICATION

### 💣 Red flag code pattern

#### Node.js

```js id="node1"
axios.get(userInput)
fetch(userInput)
http.get(userInput)
```



#### Python

```python id="py1"
requests.get(url)
urllib.request.urlopen(url)
```



#### PHP

```php id="php1"
file_get_contents($_GET['url'])
curl_exec($ch)
```



### 🧠 Rule of thumb:

> Kalau user bisa kontrol URL + server melakukan request → POTENSIAL SSRF



## 3. 🧪 VALIDATION STAGE (Proof SSRF)

### 🎯 Objective:

Bukti server benar-benar melakukan request keluar



### 🔥 Step testing basic SSRF

#### 1. External callback test

```text id="test1"
http://your-burp-collab-domain
```

atau:

* webhook.site
* interactsh
* burp collaborator

✔ kalau ada hit → SSRF confirmed



### 2. Internal probing test

```text id="test2"
http://127.0.0.1
http://localhost
http://10.0.0.1
```



### 3. Metadata cloud test

```text id="test3"
http://169.254.169.254/latest/meta-data/
```



## 4. 🧨 ADVANCED BYPASS STAGE



### 💣 A. CGNAT bypass

```text id="cgnat1"
http://100.64.0.0/10
```

#### tujuan:

* bypass naive IP blacklist
* reach internal NAT layer



### 💣 B. DNS Rebinding (TOCTOU SSRF)

```text id="dns1"
http://a9fea9fe.rbndr.us/latest/meta-data/
```

#### mekanisme:

1. validation → safe IP
2. execution → internal IP (169.254.169.254)



### 💣 C. IP parsing bypass (tambahan real-world)

* 127.1
* 0
* 2130706433 (decimal IP)
* [::1]



## 5. 🎯 IMPACT VALIDATION



### 🔥 Level 1 — Blind SSRF

* hanya outbound request
* tidak ada response

✔ bukti: collaborator hit



### 🔥 Level 2 — Internal Access

* hit localhost / internal IP
* port scan internal service

✔ bukti: response berbeda / timing



### 🔥 Level 3 — Cloud Metadata Access (CRITICAL)

target:

```text id="cloud1"
169.254.169.254
```

impact:

* AWS IAM credentials leak
* Azure metadata token leak
* GCP service account leak



### 💣 hasil akhir:

→ Cloud account takeover possible



## 6. 🛠️ ROOT CAUSE ANALYSIS (WAJIB DI REPORT)

Biasanya salah satu:

### ❌ No URL validation

### ❌ No IP allow/deny list

### ❌ DNS not pinned

### ❌ Allow raw user input to request client

### ❌ No SSRF firewall layer



## 7. 🧱 MITIGATION CHECKLIST (BUAT DEV TEAM KAMU)



### 🔐 A. Block semua internal IP ranges

* 127.0.0.0/8
* 10.0.0.0/8
* 172.16.0.0/12
* 192.168.0.0/16
* 100.64.0.0/10
* 169.254.0.0/16



### 🔐 B. DNS pinning

flow:

```
resolve → validate IP → lock → request
```



### 🔐 C. Allowlist domain (best practice)

```text id="allow1"
only allow: api.trusted.com
```



### 🔐 D. Block redirect chaining

* disable follow redirects
* or re-validate every hop



### 🔐 E. Use SSRF proxy layer

centralized fetcher:

* validates URL
* resolves DNS
* blocks internal IP



## 8. 🧠 THINKING MODEL (IMPORTANT)

kalau nemu endpoint:

> “server ngambil sesuatu dari URL user”

tanya 3 hal:

1. bisa ubah host?
2. bisa reach internal IP?
3. bisa bypass filter?

kalau iya → SSRF candidate



## 🚀 SUMMARY

SSRF hunting workflow:

```
Recon → Find URL input
→ Check server fetch behavior
→ Confirm outbound request
→ Try internal IP
→ Try bypass (CGNAT, DNS rebinding)
→ Validate impact (metadata/cloud)
```

