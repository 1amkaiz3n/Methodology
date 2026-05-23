# 📦 CORS - Bundle Recon & JavaScript Analysis

Memperdalam penemuan CORS melalui analisis JavaScript bundle.

---

## 🔍 JS Bundle Discovery

```bash
# Menemukan file JavaScript yang di-load oleh halaman target
# Tujuannya: cari bundle utama frontend untuk dianalisis
curl -s https://onevasco-chat.vfsai.com | grep -Eo 'src="[^"]+js'

# Output :
## src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js
## src="runtime.f7bca012609f6470.js
## src="polyfills.cf77fb543ab48fd3.js
## src="main.538e8d6b6e25fd45.js

# Buat folder untuk menyimpan hasil recon bundle JS
mkdir -p onevasco && cd onevasco

# Download bundle utama frontend
# Biasanya endpoint, config, auth flow ada di sini
curl -O https://onevasco-chat.vfsai.com/main.538e8d6b6e25fd45.js

# Beautify file JS supaya readable (karena bundle biasanya minified)
tmp=$(mktemp) && js-beautify main.538e8d6b6e25fd45.js > "$tmp" && mv "$tmp" main.538e8d6b6e25fd45.js
```

---

## 🔎 Recon Bundle - Basic

```bash
# Cari penggunaan Authorization header
# Indikasi endpoint yang butuh bearer token/auth
grep -R "Authorization" .

# Cari string /api untuk mapping API routes
grep -R "/api" .

# Cari keyword chat
# Biasanya ada feature chatbot/conversation endpoint
grep -R "chat" .

# Cari history endpoint
# Kadang ada endpoint retrieve conversation history
grep -R "history" .
```

---

## 📤 Extract URLs & Endpoints

```bash
# Extract full hardcoded URL dari bundle
# Useful untuk menemukan backend lain / third-party API
grep -aoE 'https?://[^"'\'' )]+' main.538e8d6b6e25fd45.js | sort -u

# Extract kemungkinan endpoint/path
# Dump semua string mirip route ke file endpoints.txt
grep -aoE '/[A-Za-z0-9._~:/?#@!$&()*+,;=%-]+' main.538e8d6b6e25fd45.js | sort -u | uniq > endpoints.txt

# Cari keyword sensitif / feature penting
# Fokus: auth, user data, admin, prompt, document, session
grep -aiE 'chat|history|message|session|token|feedback|prompt|document|admin|config|user|profile|conversation' main.538e8d6b6e25fd45.js

# Extract string route mentah yang diawali /
# Kadang lebih banyak dapet endpoint tersembunyi
strings main.538e8d6b6e25fd45.js | grep -E '^/' | sort -u

# Parsing string lebih bersih dengan split berdasarkan quote
# Kadang endpoint kebungkus string literal
cat main.538e8d6b6e25fd45.js \
| tr '"' '\n' \
| grep -E '^/?[A-Za-z0-9._/-]+$' \
| sort -u

# Cari hardcoded config auth/backend
# Misal baseUrl, OpenID, Keycloak, realm, issuer
grep -aiE 'api|baseUrl|clientId|realm|issuer|openid' main.538e8d6b6e25fd45.js
```

---

## 🗺️ Extract actual paths (bukan full URL)

Minified JS kadang path disusun string concat, jadi grep /... kurang kena.

```bash
# Extract string literal yang berupa path
# Lebih akurat untuk route yang ditulis "/xxx"
grep -aoE '"/[^"]+|'\''/[^'\'']+' main.538e8d6b6e25fd45.js \
| sed 's/^["'\'']//' \
| sort -u

# Cari path yang relevan dengan chat/backend flow
strings main.538e8d6b6e25fd45.js \
| grep -Ei '/(chat|message|history|feedback|prompt|config|user|session|document|source|admin)'
```

---

## 🔧 Cari keyword method calls

```bash
# Cari indikasi HTTP method mapping
# Kadang bundle menyimpan string seperti endpoint:POST
grep -aoE '[A-Za-z0-9_-]+:(GET|POST|PUT|DELETE)' main.538e8d6b6e25fd45.js

# Cari penggunaan Angular HTTP / fetch
# Untuk identifikasi actual API call
grep -aiE 'http\.post|http\.get|fetch\(' main.538e8d6b6e25fd45.js

# Angular biasanya ada pattern ini:
this.http.post(this.api + "/chats")

# Cari lokasi string /chats
# Supaya bisa inspect logic sekitar endpoint
grep -n "/chats" main.538e8d6b6e25fd45.js | head -20

# Inspect context sekitar /chats
# Biasanya keliatan request body/auth flow
grep -n -C 5 "/chats" main.538e8d6b6e25fd45.js
```