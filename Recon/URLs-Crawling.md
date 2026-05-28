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
# 📌 hakrawler
cat hosts | hakrawler -d 3 | sort -u | anew urls
```

```bash
# 📌 PARAMETER ENRICHMENT (OPTIONAL DISCOVERY LAYER)
cat urls | grep "=" > params.txt
```

```bash
bbot -t hosts -p spider -c web.spider_distance=2 web.spider_depth= -o .
```

> **BBBOT ini akan menghaislkn folder rnadom seperti `sophisticated_diana`,dan di dalalmnay ad beberpa file seprti `output.txt `**

## 📌 OUTPUT FILE STRUCTURE (WAJIB BIAR RAPI)

* `urls`
  → semua endpoint gabungan (wayback + katana + gau + hakrawler)

* `params.txt`
  → URL yang mengandung parameter (`?id=`, `?user=`)

