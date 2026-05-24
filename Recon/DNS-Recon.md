# Methodology DNS Recon

## 📊 Tabel Jenis Catatan DNS


| Jenis Record | Fungsi                           | Contoh                           | Relevansi di Pentest                               |
| ------------ | -------------------------------- | -------------------------------- | -------------------------------------------------- |
| **A**        | Mapping domain → IPv4            | `example.com → 93.184.216.34`    | Menemukan origin server (bypass CDN, IP discovery) |
| **AAAA**     | Mapping domain → IPv6            | `example.com → 2606:2800:...`    | Alternatif jalur akses / bypass filter IPv4        |
| **CNAME**    | Alias ke domain lain             | `api → api.cloudflare.net`       | Detect third-party service, takeover risk          |
| **MX**       | Mail server                      | `mail → mail.google.com`         | Email infra exposure, phishing surface             |
| **NS**       | Authoritative DNS server         | `ns1.cloudflare.com`             | Identify DNS provider, zone misconfig risk         |
| **TXT**      | Text record (SPF, verification)  | `v=spf1 include:_spf.google.com` | Token leak, SPF/DKIM/verification abuse            |
| **SOA**      | Start of Authority               | admin DNS zone info              | Zone transfer misconfig check                      |
| **PTR**      | Reverse DNS (IP → domain)        | `34.216.184.93 → example.com`    | Infrastructure mapping / OSINT                     |
| **SRV**      | Service discovery (port/service) | `_sip._tcp.example.com`          | Exposed internal services                          |
| **CAA**      | Certificate authority rules      | `issue "letsencrypt.org"`        | TLS issuance control, misconfig detection          |
| **NAPTR**    | Advanced service routing         | telecom/VoIP routing             | Rare, but useful for telecom infra mapping         |


>  **DNS Enumeration** adalah proses menemukan semua catatan DNS yang terkait dengan suatu domain. Proses ini dapat memberikan informasi berharga bagi peretas etis selama fase pengintaian dalam pengujian penetrasi, karena dapat mengungkap subdomain, alamat IP, dan informasi lain yang mungkin berguna untuk analisis lebih lanjut, pemetaan infrastruktur, identifikasi target yang berpotensi rentan, dan perencanaan jalur serangan. 

Tujuan dari enumerasi DNS adalah untuk menemukan semua server DNS, subdomain, dan informasi terkait DNS lainnya yang terkait dengan target. Enumerasi DNS dapat dilakukan secara manual, tetapi ini adalah proses yang memakan waktu dan rawan kesalahan. Oleh karena itu, **disarankan untuk menggunakan alat dan teknik otomatis untuk melakukan enumerasi DNS** . 

**Beberapa tujuan dari enumerasi DNS meliputi :**

  - Mengidentifikasi semua server DNS dan konfigurasinya.
  - Menemukan subdomain dan domain terkait lainnya.
  - Memetakan topologi jaringan dan mengidentifikasi potensi kerentanan.
  - Mengumpulkan informasi server email dan mengidentifikasi masalah keamanan email.
  - Mengidentifikasi kesalahan konfigurasi dan kelemahan terkait DNS yang dapat dieksploitasi dalam serangan. 

> Singkatnya, enumerasi DNS memberikan wawasan berharga tentang infrastruktur jaringan target yang dapat digunakan untuk mengembangkan rencana serangan. 


## DNS Enumeration Tools and Techniques

### Nslookup

`nslookup` adalah alat baris perintah yang digunakan untuk menanyakan server DNS secara interaktif. Ini adalah alat yang paling umum untuk memetakan nama domain ke alamat IP dan tersedia secara default di semua sistem operasi utama seperti platform Windows, Mac, dan Linux. 

```bash
nslookup -type=MX <Target> <Server DNS> 

# Contoh
nslookup -type=MX target.com 8.8.8.8
```

Pada contoh ini, kita melakukan kueri untuk semua jenis catatan DNS untuk GoDaddy.com menggunakan server DNS 8.8.8.8

## host

`host` adalah utilitas yang sangat sederhana untuk melakukan pencarian DNS. Biasanya digunakan untuk mengkonversi nama menjadi alamat IP dan sebaliknya. Tersedia di platform Linux. Untuk menggunakan `host` , buka terminal dan masukkan perintah berikut: 

```bash
host -a <DOMAIN> 
```

## Dig

`Dig` adalah alat yang fleksibel namun ampuh untuk menginterogasi server nama DNS.
Utilitas `dig` adalah alat baris perintah yang lebih canggih yang digunakan untuk resolusi dan kueri DNS. Alat ini digunakan untuk mengkueri server DNS guna mendapatkan informasi detail tentang nama domain dan catatan DNS. `dig` memiliki fitur yang lebih canggih daripada `nslookup` dan `host`, serta dapat melakukan kueri DNS yang lebih kompleks. `dig` dapat digunakan untuk melakukan validasi DNSSEC, kueri EDNS, dan fungsi DNS canggih lainnya.

Sebagian besar administrator DNS menggunakan dig untuk memecahkan masalah DNS karena fleksibilitasnya, kemudahan penggunaan, dan kejelasan outputnya. Alat pencarian lainnya cenderung memiliki fungsionalitas yang lebih sedikit daripada dig . 


```bash
dig domain.com
```

Ada beberapa opsi untuk mengekstrak hanya output atau jawaban yang relevan tanpa tambahan yang biasanya disertakan dalam output perintah ` dig` . Opsi-opsi berikut membantu mengurangi volume output dan membuatnya lebih mudah dibaca. 

- `+noall` Opsi memberi tahu dig untuk mematikan semua flag output, sehingga tidak ada informasi tambahan selain bagian jawaban yang ditampilkan.

- `+answer` Opsi memberi tahu dig untuk hanya menampilkan bagian jawaban dari hasil kueri. Ini berguna untuk menyaring informasi yang tidak relevan dan fokus pada data yang paling relevan. 

- `+short` : memberikan output yang lebih ringkas, hanya menampilkan alamat IP atau data relevan lainnya.

- `+recurse` : memberi tahu server DNS untuk secara rekursif menanyakan server DNS lain hingga mendapatkan jawaban lengkap.

- `@server` : menentukan server DNS yang akan dikueri.

- `+dnssec `: meminta informasi DNSSEC untuk kueri tersebut.

- `+time=X `: mengatur waktu maksimum agar kueri selesai menjadi X detik. Berguna saat Anda mengalami masalah dengan kueri yang mengalami batas waktu habis. 



```bash
dig <QUERY_TYPE> +<OPTION> <DOMAIN> 

# Contoh
dig ns domain.com +noall +answer
```

## Fierce 

`Fierce` adalah utilitas baris perintah yang dirancang khusus untuk pengintaian DNS dan digunakan untuk menemukan ruang IP yang tidak berdekatan dan menemukan nama domain terkait. Alat ini sangat berguna untuk melakukan enumerasi DNS dan penemuan subdomain. `Fierce` dapat melakukan transfer zona dan serangan brute-force berbasis kamus untuk menemukan subdomain baru yang tidak ada dalam file zona DNS. Yang terakhir ini sangat berguna dalam menemukan subdomain tersembunyi atau kurang dikenal. 

**Beberapa fitur utama Fierce meliputi :**

  - Transfer zona otomatis terhadap server DNS untuk mengumpulkan informasi tentang subdomain yang terkait dengan domain target.
  - Serangan brute-force berbasis kamus untuk menemukan subdomain baru
  - Output subdomain yang ditemukan ke file dalam berbagai format (CSV, XML, dll.)
  - Kemampuan untuk menentukan beberapa server DNS yang akan digunakan untuk resolusi. 

```bash
 fierce --domain <DOMAIN> 
```

## whois

`whois` adalah alat baris perintah yang digunakan untuk mengumpulkan informasi tentang suatu domain dan pemiliknya. Meskipun tidak secara khusus digunakan untuk enumerasi DNS, `whois` dapat digunakan untuk mengumpulkan informasi tentang nama domain dan alamat IP.
Masukkan ini ke dalam kategori "baik untuk diketahui" untuk pengintaian umum tentang target Anda, tetapi tidak seberguna alat lain yang dibahas dalam artikel ini dalam hal enumerasi DNS. 


```bash
whois <DOMAIN>

# atau
# Langsung buka di browser atau pake curl
curl -s "https://www.whois.com/whois/directverify.in" | grep -E "Registrant|Organization|Expires|Name Server"
```

## DNSEnum

`dnsenum` adalah alat enumerasi DNS serbaguna yang dapat melakukan berbagai tugas seperti enumerasi subdomain, pencarian IP terbalik, menemukan blok IP yang tidak berdekatan, dan melakukan transfer zona.

```bash
dnsenum --enum <DOMAIN> 
```

**Saat ini, dnsenum dapat melakukan banyak operasi pengintaian DNS, seperti operasi-operasi berikut :**

  - Dapatkan catatan A, MX, dan NS yang biasa untuk suatu domain.
  - Lakukan kueri transfer zona (AXFR) pada nameserver.
  - Temukan subdomain tambahan melalui pengikisan data Google.
  - Pencarian paksa subdomain dari sebuah file juga dapat melakukan kueri rekursif pada subdomain yang memiliki catatan NS.
  - Lakukan pencarian terbalik pada rentang jaringan.
  - Hitung rentang jaringan domain kelas C dan lakukan kueri whois pada rentang tersebut. 

## Knockpy

`Knock` adalah alat Python yang sangat mudah dikonfigurasi dan modular yang digunakan untuk melakukan enumerasi DNS dengan melakukan serangan brute-force pada subdomain. 

**Perangkat ini mendukung pemindaian berikut :**

```bash
* SCAN
full scan:      knockpy domain.com
quick scan:     knockpy domain.com --no-local
faster scan:    knockpy domain.com --no-local --no-http
ignore code:    knockpy domain.com --no-http-code 404 500 530
silent mode:    knockpy domain.com --silent

* SUBDOMAINS
show recon:     knockpy domain.com --no-local --no-scan
```


```bash
knockpy tryhackme.com -o report 
```

Ini akan melakukan pemindaian penuh enumerasi DNS pada domain tryhackme.com dan juga akan melakukan brute-force pada subdomain potensial untuk menemukan informasi tambahan. Salah satu opsi penting adalah -oflag yang menentukan format file output. Pada contoh di atas, kita telah menyimpan hasilnya dalam format JSON. 


## DNSRecon

`dnsrecon` adalah kerangka kerja pemindaian dan enumerasi DNS komprehensif yang dapat melakukan berbagai tugas seperti enumerasi subdomain, transfer zona, dan analisis catatan DNS. Alat ini cukup ampuh, kaya fitur, dan layak mendapatkan artikel tersendiri yang didedikasikan untuk fungsinya. 



**Fitur DNSRecon meliputi :**

  - Memeriksa semua catatan NS untuk transfer zona.
  - Mencantumkan catatan DNS umum untuk domain tertentu.
  - Melakukan enumerasi catatan SRV umum.
  - Memeriksa resolusi wildcard.
  - Melakukan serangan brute force pada subdomain dan catatan host menggunakan domain dan daftar kata.
  - Melakukan pencarian (terbalik) catatan PTR untuk rentang IP atau CIDR tertentu.
  - Memeriksa catatan cache server DNS untuk A, AAAA, dan CNAME.
  - Mencantumkan host dan subdomain menggunakan Google scraping. 

> dnsrecon memiliki banyak fitur dan opsi yang perlu Anda jelajahi.
> Salah satu opsi penting saat melakukan serangan brute force DNS adalah... `-f`.

```bash
uv run dnsrecon -f -d <DOMAIN> 
```

## Nmap

Nmap bawaan juga menyediakan serangkaian skrip yang dapat digunakan untuk melakukan enumerasi DNS, brute-forcing, dan analisis menggunakan Nmap Scripting Engine (NSE) . 

```bash
nmap -p 53 --script=dns-brute --script-args=  "dns-brute.domain=cnn.com"  cnn.com 
```

**Untuk melihat daftar lengkap skrip DNS nmap, gunakan perintah berikut :**
```bash
ls -la  /usr/share/nmap/scripts/*dns* | rev | cut -d "/" -f1 | rev
```