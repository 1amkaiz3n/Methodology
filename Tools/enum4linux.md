# enum4linux 

SMB/Windows Enumeration Tool

```bash
enum4linux <target-ip>
```

## 📌 Fungsi utama

Tool wrapper untuk enumerasi **SMB / Windows / Samba**:

* user enumeration
* share enumeration
* group enumeration
* OS fingerprint
* password policy
* RID cycling (user brute SID)




## 👤 User enumeration

```bash
enum4linux -U <target>
```

→ daftar user Windows/Samba



## 📁 Share enumeration

```bash
enum4linux -S <target>
```

→ list SMB shares



## 👥 Group enumeration

```bash
enum4linux -G <target>
```

→ group + member list



## 🔐 Password policy

```bash
enum4linux -P <target>
```

→ policy password domain (length, lockout, complexity)



## 🖥 OS info

```bash
enum4linux -o <target>
```

→ OS fingerprint Windows / Samba



## 🖨 Printer info

```bash
enum4linux -i <target>
```

→ printer share (jarang penting)



## 🌐 NetBIOS / domain discovery

```bash
enum4linux -n <target>
```

→ NetBIOS name table (workgroup/domain)



## 📡 RID cycling (IMPORTANT)

```bash
enum4linux -r <target>
```

→ brute SID → user enumeration



```bash
enum4linux -R 500-550,1000-1050 <target>
```

→ custom RID range



## 🔁 Full auto enumeration (PENTEST DEFAULT)

```bash
enum4linux -a <target>
```

Equivalent:

* -U
* -S
* -G
* -P
* -r
* -o
* -n
* -i



## 🧠 Verbose mode (lihat tool internal)

```bash
enum4linux -v <target>
```

→ menunjukkan command internal:

* smbclient
* rpcclient
* net
* nmblookup



## 📂 Share brute force

```bash
enum4linux -s wordlist.txt <target>
```



## 👤 Known user helper (SID lookup)

```bash
enum4linux -k administrator,guest <target>
```



## 🌍 Workgroup manual

```bash
enum4linux -w WORKGROUP <target>
```



## ⚡ Aggressive mode

```bash
enum4linux -A <target>
```

→ write check on shares + lebih invasive



## 🧩 Dependensi (internal tools yang dipakai)

enum4linux sebenarnya wrapper dari:

* `smbclient` → akses SMB share
* `rpcclient` → user / SID / domain query
* `nmblookup` → NetBIOS discovery
* `net` → Windows session & domain info
* `ldapsearch` → AD query (kalau domain controller)
* `polenum` → password policy parsing



## 🚨 Syarat target valid

Harus ada:

* TCP 139 / 445 OPEN
* SMB service aktif
* Windows / Samba exposed

Kalau tidak:
→ output kosong / timeout / no session



## 🧠 Ringkasan mental model

```
enum4linux = SMB recon automation layer
```

* nmap → cari port
* enum4linux → eksploitasi info SMB
* rpcclient/smbclient → engine di belakangnya

