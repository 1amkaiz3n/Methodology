# Nmap

```bash
nmap -sV -sC -p  <IP>
```

```bash
nmap -Pn -sC -sV -oA nmap/quick <IP>
```

```bash
sudo nmap -sS -p- --open --min-rate 5000 -vvv -n -Pn <IP>> -oG OpenPorts
```

mengidentifikasi semua port yang terbuka pada target. Hasilnya akan disimpan ke dalam file bernama “OpenPorts.” Selanjutnya, saya akan melakukan pemindaian “-sVC”, yang akan menggunakan skrip mesin skrip Nmap (NSE) umum untuk mendeteksi layanan dan versinya. 

```bash
sudo nmap -sVC -p80,135,139,445,5985,47001,49664,49665,49666,49667,49668,49669,49670 <IP> -oN sVCScan 
```

menjalankan skrip kerentanan Nmap untuk mengidentifikasi kerentanan umum. 
```bash
sudo nmap -script vuln <IP> -oN VulnScan
```

```bash
```

```bash
```

```bash
```