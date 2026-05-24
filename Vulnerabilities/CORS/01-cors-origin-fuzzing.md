# 🎯 CORS - Origin Fuzzing & Basic Testing

Methodology untuk melakukan fuzzing origin dan testing dasar CORS misconfiguration.

---

## 📋 List Origin yang bisa di tes

```bash
Origin: null
Origin: https://evil.com.target.com
Origin: https://target.com.evil.com
Origin: https://sub.target.com.evil.com
Origin: http://evil.com
Origin: https://evil.com%60target.com
Origin: https://evil.com%2etarget.com
```

---

## 🚀 Menggunakan meg

```bash
meg --verbose --header "Origin: https://evil.com" paths hosts cors_out

# CARI
grep -Rni "Access-Control-Allow-Origin: https://evil.com" cors_out/

## Lanjut cari asal reflected nya, misalnya ada di feedback.post.ch/1c29555df
grep -Rni "Access-Control-Allow-Origin" cors_out/feedback.post.ch/1c29555df*
```

---

## 🔍 Menggunakan corscanner

```bash
# Aktifkan env
source /myenv/bin/activate 

# Basic
corscanner -u https://example.com

# Spesific urls
corscanner -u https://example.com/restapi

# Spesific header
corscanner -u https://example.com -d "Cookie: test"

# enable proxy
corscanner -u https://example.com -p http://127.0.0.1:8080

# Dari file urls
cat urls | grep -v '^$' | while read url; do
  echo "[*] scanning $url"
  corscanner -u "$url"
done

# Dari file hosts
cat hosts | grep -v '^$' | while read url; do
  echo "[*] scanning $url"
  corscanner -u "$url"
done
```

---

## 🎯 Menggunakan Burp Suite

```bash
# Step 1: Configure Burp to test CORS
# Proxy > Options > Match and Replace
# Add rule: 
# Type: Request header
Match: ^Origin: .*
Replace: Origin: https://evil.com
```
