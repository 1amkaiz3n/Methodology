# 403 → DNS Enum → Origin IP Discovery → Backend Misconfig Exploitation

Diawali 403 di domain → cari IP origin → bypass CDN/WAF → exploit misconfigured backend 

## CDN Detection — pisahin yang pakai CDN

Dari live hosts, deteksi mana yang pakai CDN (Cloudflare, Akamai, Fastly, dll) lewat CNAME chain. Yang pakai CDN = kandidat untuk dicari origin IP-nya.

```bash
cat hosts | httpx -silent -cname -status-code   | grep -iE "cloudflare|akamai|fastly|cloudfront|incapsula"   | awk '{print $1}'  | sed 's|https://||g' > cdn_targets.txt
```

## DNS Resolution — resolve semua IP per domain

Resolve DNS untuk dapat semua A record. Pakai -resp-all supaya dapet semua IP (load balancer sering punya 2-3 node, beda config tiap nodenya).

```bash
dnsx -l cdn_targets.txt -a -resp-all -silent -retry 5 \
  > resolved_all.txt
```

```bash
# Ekstrak IP bersih
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' resolved_all.txt \
  | sort -u > origin_ips.txt
```
## Filter IP CDN
origin_ips.txt bisa masih isinya IP Cloudflare
Setelah dnsx resolve, IP yang keluar bisa aja masih IP CDN bukan origin. Perlu dibuang dulu sebelum probe, biar httpx-nya nggak buang waktu probe IP yang salah.

```bash
# Download range IP Cloudflare
curl -s https://www.cloudflare.com/ips-v4 > /tmp/cf_ranges.txt

# Filter buang IP yang masuk range CDN
mapcidr -l /tmp/cf_ranges.txt -silent \
  | sort > /tmp/cf_expanded.txt

comm -23 \
  <(sort origin_ips.txt) \
  <(sort /tmp/cf_expanded.txt) \
  > origin_ips_clean.txt
```

## Passive origin IP hunting
DNS aktif aja tidak cukup — SPF & MX sering bocahin origin
TXT record (SPF) dan MX record sering dikonfigurasi oleh orang yang sama dengan yang setup server. Hasilnya sering nyebut IP origin langsung — bahkan setelah domain dipasang CDN.

```bash
# Cek SPF & MX record per domain CDN target
while read domain; do
  # SPF → sering ada ip4: yang nunjuk origin
  dig +short TXT $domain \
    | grep -oE 'ip4:[0-9.]+' \
    | sed 's/ip4://'
  # MX → kadang resolve ke IP origin
  dig +short MX $domain \
    | awk '{print $2}' \
    | xargs -I{} dig +short {}
done < cdn_targets.txt \
  | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
  | sort -u >> origin_ips_clean.txt

sort -u origin_ips_clean.txt -o origin_ips_clean.txt
```


## IP Probing — cek tiap IP langsung

Probe langsung ke IP tanpa Host header. Yang return beda dari 403 (200, 301, 302 ke /admin dst) = origin exposed. Ini yang jadi target utama.

```bash
httpx -l origin_ips.txt \
  -silent -status-code -title \
  -web-server -tech-detect \
  -follow-redirects \
  > ip_probe_results.txt
```

```bash
# Pisahin yang menarik (bukan 403/400)
grep -vE " \[403\]| \[400\]" ip_probe_results.txt \
  > ip_exposed.txt
```

httpx default cuma probe 80 dan 443. Tapi origin yang exposed sering jalan di 8080, 8443, 8888, 9090 — terutama staging dan UAT environment. Ini sering kelewat.

```bash
# bisa juga:
httpx -l origin_ips_clean.txt \
  -ports 80,443,8080,8443,8888,9090 \
  -silent -status-code -title \
  -web-server -tech-detect \
  -follow-redirects \
  > ip_probe_results.txt
```

## SSL Cert SAN Leak — pivot ke domain tersembunyi

Dari IP yang exposed, baca SSL certificate-nya. SAN (Subject Alternative Names) sering bocahin subdomain internal, staging, atau domain lain yang sama origin.

```bash
while read ip; do
  echo "=== $ip ==="
  echo | openssl s_client -connect $ip:443 2>/dev/null \
    | openssl x509 -noout -text \
    | grep -oP '(?<=DNS:)[^\s,]+'
done < <(awk '{print $1}' ip_exposed.txt) \
  > san_leak.txt
```

## Backend Fingerprint — identifikasi framework & probe endpoint

Dari IP yang exposed, fingerprint backend-nya lalu probe endpoint default per framework. Ini yang menentukan apakah ada misconfiguration yang bisa dieksploitasi.

```bash
# Contoh endpoint per framework
# Directus  → /server/info  /server/specs/oas  /items/*
# Laravel   → /api/user  /_ignition/health-check
# Strapi    → /admin  /api/users/me
# Grafana   → /api/health  /api/datasources
# Jenkins   → /api/json  /asynchPeople/api/json
```

```bash
while read ip; do
  for path in /server/info /api/user /admin /api/health; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" https://$ip$path)
    echo "$ip$path → $code"
  done
done < <(awk '{print $1}' ip_exposed.txt) \
  > endpoint_probe.txt
```

```bash
grep -v "→ 403\|→ 404\|→ 000" endpoint_probe.txt \
  > endpoint_hits.txt
```


**Output files :**
  - cdn_targets.txt
  - resolved_all.txt 
  - origin_ips.txt 
  - ip_probe_results.txt 
  - ip_exposed.txt 
  - san_leak.txt 
  - endpoint_probe.txt 
  - endpoint_hits.txt 