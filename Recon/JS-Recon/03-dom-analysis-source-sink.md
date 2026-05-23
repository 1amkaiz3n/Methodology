# 🔎 3 - DOM Analysis, Source & Sink

Proses untuk recon setelah kita download semua file JS, fokus pada DOM-based vulnerabilities.

---

## 🔥 STEP 1 — Cari SOURCE

```bash
rg "location\.search|URLSearchParams|document\.referrer|window\.name" js-download/
```

---

## 🔥 STEP 2 — Scan SINK

```bash
rg "eval\(|Function\(|innerHTML|postMessage|location\.search|URLSearchParams" js-download/
```

---

## 🔥 STEP 3 — Cari SOURCE → SINK chain (versi rg yang benar)

```bash
rg "location\.search|URLSearchParams" js-download/ | xargs rg "innerHTML|eval\(|Function\("
```

```bash
rg "location\.search|URLSearchParams" raw/ | xargs rg "innerHTML|eval\(|postMessage"
```

---

## 🔥 Upgrade penting (biar lebih tajam)

Kalau mau lebih "hunter mode", tambahin ini untuk cari DOM injection tambahan:

```bash
rg "insertAdjacentHTML|outerHTML|document\.write" v/
```

---

## 🔥 Cari DOM XSS / injection point

```bash
grep -RniE "innerHTML|document.write|eval\(|setTimeout\(|Function\(" file.js
```

**Ini penting buat:**
- XSS vector
- template injection
- unsafe rendering

---

## 🔥 Cari Sink

```bash
grep -Rni "innerHTML\|outerHTML\|insertAdjacentHTML" swagger-ui-beautifier.js
```

```bash
grep -Rni "sanitize(" swagger-ui-beautifier.js
```

---

## 🔥 Cari render sink (khusus Swagger UI)

```bash
grep -Rni "render\|rendered\|append\|html(" swagger-ui-beautifier.js
```

```bash
# Cari Handlebars injection flow
grep -Rni "Handlebars\.template\|compile\|templates\[" swagger-ui-beautifier.js
```

```bash
# Cari input source dari swagger spec
grep -Rni "swagger.json\|/api-docs\|openapi\|spec" swagger-ui-beautifier.js
```

---

## 🧠 Finding Hidden APIs and Functionality

### Uncovering Internal APIs

Contoh:

```bash
fetch("https://api.target.com/internal/feature_flag")
```

```bash
axios.post("/admin/debug-mode", payload)
```

### Penyalahgunaan Feature Flag

Anda mungkin menemukan:

```bash
if (window.localStorage.getItem("enableBeta") === "true") {
   renderBetaUI();
}
```

Aktifkan melalui DevTools:

```bash
localStorage.setItem("enableBeta", "true"); location.reload();
```

Atau periksa apakah parameter URL mengaktifkan alur tersembunyi:

```bash
https://target.com/dashboard?debug=true
```

### Mengidentifikasi Endpoint yang Usang atau Warisan

Banyak aplikasi web masih mempertahankan dukungan lama:

```bash
/v1/user/update
/v2/user/update
```

Kadang-kadang `/v1/` logika tersebut kurang memiliki otentikasi atau validasi modern. JavaScript mungkin akan menampilkan perilaku cadangan:

```bash
if (version === 'v1') useOldHandler();
```

### Kueri Tersembunyi GraphQL

Periksa apakah JavaScript berisi operasi GraphQL:

```graphql
query getUserData($id: ID!) {
   user(id: $id) {
      email, role, token
   }
}
```

---

## 🧪 Advanced JS RE Techniques

### Logika yang Dikaburkan

Mencari:
- Nama variabel acak (misalnya, `_0x12abf1`)
- Panggilan fungsi yang dikodekan (`eval(atob(...))`)
- Pembungkus fungsi dan pengubahan string

Menggunakan:
- `de4js` untuk mendekode
- Chrome DevTools untuk mengatur breakpoint dan memeriksa variabel
- Penggantian nama secara manual untuk kejelasan

### Debugging di DevTools

- Buka browser DevTools (tab Sumber)
- Cetakan cantik (`{}` ikon) skrip terpaket apa pun
- Tetapkan breakpoint di tempat yang menarik (`fetch()` panggilan)
- Lacak jalur fungsi
