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
# buat paths dulu
cat urls | unfurl path | sort -u > paths 
```

```bash
meg --verbose --header "Origin: https://evil.com" paths hosts cors_out
```

```bash
# CARI
grep -Rni "Access-Control-Allow-Origin: https://evil.com" cors_out/
```

```bash
## Lanjut cari asal reflected nya, misalnya ada di feedback.target.com/1c29555df
grep -Rni "Access-Control-Allow-Credentials: true" cors_out/feedback.target.com/1c29555df*
```

---

## 🔍 Menggunakan corscanner

```bash
# Aktifkan env
source /myenv/bin/activate 
```

```bash
# Basic
corscanner -u https://example.com
```

```bash
# Spesific urls
corscanner -u https://example.com/restapi
```

```bash
# Spesific header
corscanner -u https://example.com -d "Cookie: test"
```

```bash
# enable proxy
corscanner -u https://example.com -p http://127.0.0.1:8080
```

```bash
# Dari file urls
cat urls | grep -v '^$' | while read url; do
  echo "[*] scanning $url"
  corscanner -u "$url"
done
```

```bash
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

