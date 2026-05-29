# curl

## Simpan Cookie

```bash
curl -sk -I  "https://target.com" -c cookies.txt
```

## Cookie dari file

```bash
curl -sk -I  "https://target.com" -H "Cookie: $(cat cookies.txt)" 
```