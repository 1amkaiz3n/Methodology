# 📥 1 - Pengumpulan URL JavaScript

Methodology untuk mengumpulkan semua URL JS dari target.

---

## 🛠 Persiapan Awal

```bash
mkdir js
```

---

## 🌐 Ambil URL file JS dari web langsung

**Ada dua opsi:**

### Opsi 1 - Dari web langsung

```bash
katana -u https://shop.post.ch/en -d 5 -jc | grep '\.js$' | tee -a js/alljs.txt

echo "https://shop.post.ch/en" | waybackurls | grep '\.js$' | sort -u | anew js/alljs.txt
```

```bash
curl -s "https://shop.post.ch/en/checkout/addresses" \
| grep -Eo '(https?:)?//[^"]+\.js[^"]*' \
| sort -u > js/jscdx.txt
```

### Opsi 2 - Dari list URLs hasil crawling

```bash
grep -E "\.js(\?|$)" urls | anew js/alljs.txt
```

> Bisa pakai salah satu, atau keduanya

---

## 🎯 Grab JS dari live subdomains

```bash
cat hosts | subjs | sort -u > live_subjs_js.txt

cat hosts | getJS | sort -u > live_getjs_js.txt

katana -list hosts -d 2 -jc -silent | grep -E '\.js([?#].*)?$' | sort -u > live_katana_js.txt
```

```bash
linkfinder -i https://www.example.com -d -o cli | sort -u | tee linkfinder_raw.txt

# Ekstrak hanya URL untuk domain target kita 
grep -Eo 'https?://[^ )"]+example\.com[^ )"]*' linkfinder_raw.txt | sort -u > linkfinder_urls.txt 

# Filter URL yang mengarah ke file JS 
grep -E '\.js([?#].*)?$' linkfinder_urls.txt | sort -u > live_linkfinder_js.txt
```

---

## 📦 Ambil JavaScript dari URL yang diarsipkan

```bash
gau --subs < domains | grep -E '\.js([?#].*)?$' | sort -u > archive_gau_js.txt 

waybackurls < domains | grep -E '\.js([?#].*)?$' | sort -u > archive_wayback_js.txt

cat archive_gau_js.txt archive_wayback_js.txt | subjs | sort -u > archive_subjs_js.txt

cat archive_gau_js.txt archive_wayback_js.txt | getJS | sort -u > archive_getjs_js.txt
```

---

## 🔗 Menggabungkan dan membersihkan file JS

```bash
sort -u live_*js.txt archive_*js.txt > all_js_files.txt
```

```bash
# Opsional: Filter berdasarkan domain atau kata kunci 
grep -E '\.example\.com' all_js_files.txt > all_js_example.txt
```

---

## 🎯 Live URLS (filter status 200)

```bash
cat js/alljs.txt | uro | sort -u | httpx -mc 200 -o js/live-js
```

---

## 📥 Download semua file JS untuk analisis offline

```bash
mkdir -p js_files

# Clear the hash_map.txt
> js_files/hash_map.txt

# One containing hashed filenames, and another containing the hash-to-URL mapping.
while read -r url; do
    hash=$(echo "$url" | md5sum | cut -d' ' -f1)
    echo "$hash $url" >> js_files/hash_map.txt
    curl -skLf --compressed "$url" -o "js_files/${hash}.js"
done < all_js_files.txt
```

Jika menemukan sesuatu yang menarik dalam sebuah file (misalnya, `d41d8cd98f.js`), kita dapat cepat melacaknya kembali:

```bash
grep d41d8cd98f js_files/hash_map.txt
```

---

## 🔍 Alternative download method

```bash
mkdir -p js-download

cat js/live-js | xargs -P8 -I{} sh -c '
url="{}"
filename=$(echo "$url" | md5sum | cut -d" " -f1).js

curl -s -L --max-time 20 --retry 2 --retry-delay 1 \
  "$url" -o "js-download/$filename"
'
```

---

## 🎨 Beautify downloaded files

```bash
for file in js_files/*.js; do js-beautify "$file" -o beautified/$(basename "$file"); done
```

Atau:

```bash
find . -name "*.js" -exec js-beautify {} -o {}.beautified \;
```
