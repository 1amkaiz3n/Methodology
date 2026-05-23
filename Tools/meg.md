# meg

## Basic

```bash
# buat paths dulu
cat urls | unfurl path | sort -u > paths 
```

```bash
# ini akan menyimpn ke dalam folder out
meg --verbose paths hosts
```

## Cari Server
```bash
grep -Hnri '< Server:' out/
```

## rawhttp

```bash
meg -v -r "/%%0a0afoo:bar" hosts rawhttp_out
```

Cari

```bash
# server error unik
grep -rni "500 Internal Server Error" rawhttp_out
grep -rniE "HTTP/.* 50[0-9]" rawhttp_out

# reflected payload
grep -rni "foo:bar" rawhttp_out
grep -rni "%%0a0a" rawhttp_out

# proxy / WAF weirdness
grep -rniE "nginx|cloudflare|akamai|access denied|forbidden" rawhttp_out
```

## Path-Based XSS

```bash
meg -v -r "/footle%3c%22bootle" hosts xss_out

# filter reflection
grep -hriE '(footle<|"bootle)'

grep -Rni "footle" out/

# Verifikasi
## 1. cek apakah masuk HTML
curl -s "https://target/footle<\"bootle" | grep footle

## 2.check redirect injection
curl -i "https://target/footle%2f%2fevil.com"

# 3. cek context injection /  verify encoding
curl -i "https://target/footle%3Ctest%3E"
```

## CRLF Injection

```bash
meg -v -c 80 "/%0d%0aSet-Cookie:crlf=injection" hosts crlf_out
## output ke crlf_out

# FILTER

## cari indikasi header injection
grep -Rni "Set-Cookie" crlf_out | grep -i crlf


## cari redirect injection
grep -Rni "Location" crlf_out | grep -i "%0d%0a\|%0a"

## cari response yang mungkin split header
grep -Rni "HTTP/" crlf_out | grep -i "Set-Cookie"


# VALIDASI MANUAL
## basic CRLF test
curl -i "https://target/%0d%0aSet-Cookie:crlf=injection"

## follow redirect chain
curl -i -L "https://target/%0d%0aSet-Cookie:crlf=injection"

## check response header injection
## Cai di output: 
## Set-Cookie: crlf=injection
## Set-Cookie: injected_value
curl -i "https://row2.vfsglobal.com/%0d%0aSet-Cookie:crlf=injection"
curl -i -H "X-Forwarded-Host: evil.com%0d%0aSet-Cookie:crlf=1" https://row2.vfsglobal.com/%0d%0aSet-Cookie:crlf=injection

curl -i -H "X-Forwarded-Host: evil.com%0d%0aSet-Cookie:crlf=1" https://row2.vfsglobal.com
```


## Open Redirect

```bash
meg -v -c 80 "///example.com/%2f.." hosts open_redirect_out
## output ke open_redirect_out
# Cari
grep -hri 'Location: //example.com' open_redirect_out/
```

## CORS Config Error

```bash
meg --verbose --header "Origin: https://evil.com" paths hosts cors_out

# CARI
grep -Rni "Access-Control-Allow-Origin: https://evil.com" cors_out/

## Lanjut  cari asal reflected nya,misakan ad di feedback.post.ch/1c29555df
grep -Rni "Access-Control-Allow-Origin" cors_out/feedback.post.ch/1c29555df*
```