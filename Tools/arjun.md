# Arjun

Arjun adalah alat Python yang melakukan serangan brute-force pada parameter HTTP tersembunyi (seperti ?user_id=123(dalam URL) yang tidak terlihat dalam formulir, API, atau dokumentasi. Parameter ini seringkali dibiarkan tanpa perlindungan dan dapat menyebabkan kerentanan kritis seperti injeksi SQL, IDOR, atau kebocoran data. 

## Find Hidden Parameters

### Basic Scanning & Output

Scan satu URL untuk parameter tersembunyi. 

```bash
arjun -u https://example.com/api/v1/user
```

Simpan hasil ke format JSON untuk otomatisasi. 

```bash
arjun -u https://example.com/login -oJ params.json
```

Simpan hasil dalam teks yang mudah dibaca manusia. 

```bash
arjun -u https://example.com/profile -oT params.txt
```

### Stealth & Performance Tuning

Tambahkan jeda antar Request. 

```bash
arjun -u https://example.com -d 2  # penundaan 2 detik 
```

Tingkatkan jumlah thread untuk mempercepat proses. 

```bash
arjun -u http://internal-app:8080 -t 10  # 10 thread 
```

Batasi Request per detik. 

```bash
arjun -u https://example.com --rate-limit 5  # 5 Request/detik 
```

Utamakan keandalan daripada kecepatan. 

```bash
arjun -u https://fragile-old-app.com --stable
```

### Advanced Parameter Discovery

Gunakan wordlists. 

```bash
arjun -u https://example.com -w salesforce_params.txt
```

Kirim parameter secara bertahap. 

```bash
arjun -u https://api.example.com -c 5  # 5 parameter per request 
```

Sesuaikan dengan konvensi penamaan parameter.

```bash
arjun -u https://react-app.example.com --casing camel
```

### Complex Workflows

Uji endpoint/API POST. 

```bash
arjun -u https://example.com/login -m POST
```

Tambahkan token otentikasi atau cookie. 

```bash
arjun -u https://example.com/dashboard --headers "Cookie: session=123"
```

Masukkan data statis (misalnya, API Keys). 

```bash
arjun -u https://api.example.com --include "token=xyz" -m POST
```

### Recon & Automation

Bulk-scan URLs from a file.

```bash
arjun -i urls.txt
```

Temukan parameter melalui Wayback Machine/CommonCrawl. 

```bash
arjun --passive example.com  # Hanya menggunakan data historis 
```

Kirim hasil langsung ke Burp Suite. 

```bash
arjun -u https://example.com -oB  # Proxy ke Burp 
```

### Edge Cases & Troubleshooting

Handle redirect loops.

```bash
arjun -u https://example.com/old-page --disable-redirects
```

Tingkatkan batas waktu (timeout) untuk server yang lambat. 

```bash
arjun -u https://slow-api.example.com -T 30  # Batas waktu 30 detik 
```

Mode Quiet/senyap untuk pembuatan skrip/otomatisasi. 

```bash
arjun -u https://example.com -q -oJ params.json
```

```bash
```