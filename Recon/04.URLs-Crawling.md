# 📌 URL Collection (Active + Historical + Hybrid)

```bash
# 📌 HISTORICAL URLS
cat hosts | waybackurls | sort -u | anew urls
cat hosts | gau --subs --threads 10 | sort -u | anew urls
```

```bash
# 📌 LIVE CRAWLING (ACTIVE)
katana -list hosts -d 5 -jc -kf all | sort -u | anew urls
katana -list hosts -d 5 -silent -ef css,js,png,jpg,jpeg,svg | anew urls
```

```bash
# 📌 JAVASCRIPT-BASED ENDPOINTS
cat hosts | hakrawler -depth 3 -plain | sort -u | anew urls
```

```bash
# 📌 PARAMETER ENRICHMENT (OPTIONAL DISCOVERY LAYER)
cat urls | grep "=" > params.txt
```


## 📌 OUTPUT FILE STRUCTURE (WAJIB BIAR RAPI)

* `urls`
  → semua endpoint gabungan (wayback + katana + gau + hakrawler)

* `params.txt`
  → URL yang mengandung parameter (`?id=`, `?user=`)

