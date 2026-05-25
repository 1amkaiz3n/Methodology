# Origin IP Leakage through DNS & Load Balancer Analysis


## Sub Enum

```bash
subfinder -dL wildcards | anew domains && \
cat wildcards | assetfinder --subs-only | sort -u | anew domains
```

**Penjelasan:**
Tahap ini digunakan untuk mengumpulkan seluruh subdomain yang mungkin terkait dengan target dari berbagai sumber. Hasilnya adalah daftar domain awal yang akan dipakai untuk semua proses recon berikutnya.

**Output:**

* domains → daftar semua subdomain hasil enumerasi
* (sementara belum dicek hidup/mati atau resolvable)



## FILTER LIVE HOST

```bash
cat domains | httpx -silent -threads 200 \
-follow-redirects \
-status-code \
-title \
-tech-detect \
-content-length \
-web-server \
-ip \
-cname \
-location \
| tee live_hosts_info
```

**Penjelasan:**
Tahap ini melakukan HTTP probing ke semua subdomain untuk melihat mana yang aktif secara web. Sekaligus mengumpulkan metadata seperti status code, teknologi, IP, server, dan redirect behavior.

**Output:**

* live_hosts_info → daftar host yang aktif beserta detail HTTP response



## Filter 403 & 401


```bash
mkdir 403-Bypass
```

```bash
# Langsung pake grep buat ambil domain 403
awk '$0 ~ /\[.*403.*\]/ {print}' live_hosts_info  > ../403-Bypass/403.txt
awk '$0 ~ /\[.*401.*\]/ {print}' live_hosts_info  > ../403-Bypass/401.txt
```

Satukan :

```bash
cat ../403-Bypass/403.txt ../403-Bypass/401.txt | sort -u | anew ../403-Bypass/candidat.txt
```

**Penjelasan:**
Tahap ini menyaring semua host yang merespons HTTP 403 (Forbidden)dan 401 (Unauthorized) untuk analisa lebih lanjut. Ini penting karena menunjukkan endpoint yang aktif tetapi dibatasi aksesnya.

**Output:**

* 403.txt → daftar host yang menghasilkan response 403
* 401.txt → daftar host yang menghasilkan response 401


## Extract domain & IP

```bash
# ambil domain dari httpx
cat ../403-Bypass/candidat.txt | awk '{print $1}' | sed 's|https://||g' | cut -d'/' -f1 | sort -u > ../403-Bypass/http_domains.txt
```

```bash
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' ../403-Bypass/candidat.txt | anew ../403-Bypass/ips.txt
```


## Ambil semau IP dari list domain

Tujuan ini adalh untuk mendaptan ip lain dari subdomain yang mungkin bisa di akses

```bash
dnsx -l ../403-Bypass/http_403_domains.txt -a -resp-only  -silent -retry 5 | anew ../403-Bypass/ips.txt
```



## IP REALITY CHECK (HOST HEADER / SHARED IP)

```bash
httpx -l ../403-Bypass/ips.txt -ip -status-code -title -web-server -tech-detect -content-length -location  > ../403-Bypass/ip_probe.txt
```

## NODE GROUPING

**Tujuan :** kelompokkan IP yang punya behavior sama

```bash
httpx -l ../403-Bypass/ips.txt -ip -status-code -title -web-server -tech-detect -cname -silent > ../403-Bypass/ip_fingerprint.txt
```


## Testing

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while read ip; do
  echo -e "${BLUE}========================${NC}"
  echo -e "${BLUE}IP: $ip${NC}"
  echo -e "${BLUE}========================${NC}"

  while read domain; do

    code=$(curl -sk --max-time 5 "https://$ip" \
      -H "Host: $domain" \
      -o /dev/null \
      -w "%{http_code}")

    # ❌ skip kalau 000
    if [[ "$code" == "000" ]]; then
      continue
    fi

    if [[ "$code" == "200" ]]; then
      color=$GREEN
    elif [[ "$code" == "301" || "$code" == "302" ]]; then
      color=$YELLOW
    elif [[ "$code" == "403" || "$code" == "401" ]]; then
      color=$RED
    else
      color=$NC
    fi

    echo -e "$ip -> $domain -> ${color}$code${NC}"

  done < ../403-Bypass/http_domains.txt

done < ../403-Bypass/ips.txt
```

Atau lebih cepat

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

THREADS=30

while read ip; do
  echo -e "${BLUE}========================${NC}"
  echo -e "${BLUE}IP: $ip${NC}"
  echo -e "${BLUE}========================${NC}"

  cat ../403-Bypass/http_domains.txt | xargs -P $THREADS -I{} bash -c '
    ip="'"$ip"'"
    domain="{}"

    code=$(curl -sk --max-time 4 "https://$ip" \
      -H "Host: $domain" \
      -o /dev/null \
      -w "%{http_code}")

    [[ "$code" == "000" ]] && exit 0

    if [[ "$code" == "200" ]]; then
      color="\033[0;32m"
    elif [[ "$code" == "301" || "$code" == "302" ]]; then
      color="\033[1;33m"
    elif [[ "$code" == "403" || "$code" == "401" ]]; then
      color="\033[0;31m"
    else
      color="\033[0m"
    fi

    echo -e "$ip -> $domain -> ${color}$code\033[0m"
  '

done < ../403-Bypass/ips.txt
```

## WAF DETECTION 


```bash
wafw00f target.com
```

Atau cek semuanya sekaligus

```bash
while read target; do
    echo "Testing: $target"
    wafw00f https://$target -o ../403-Bypass/${target}.json -f json
done < ../403-Bypass/targets.txt
`