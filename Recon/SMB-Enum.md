# 🪟 enum4linux (SMB / Windows Enumeration Toolkit)

```bash
enum4linux -v target.com
```

---

## 🌐 Workgroup / Domain discovery

```bash
nmblookup -A <target>
```

```bash
nbtscan <target>/24
```

```bash
nmap -p 139 --script smb-os-discovery <target>
```

---

## 👤 User enumeration (RID cycling / SAMR)

```bash
rpcclient -U "" <target>
```

Inside rpcclient:

```bash
enumdomusers
queryuser 500
querygroup 512
```

```bash
enum4linux -U <target>
```

---

## 📁 Share enumeration (SMB shares)

```bash
smbclient -L //<ip> -N
```

```bash
enum4linux -S <target>
```

```bash
nmap -p 445 --script smb-enum-shares <target>
```

---

## 🔐 Null session test (anonymous access)

```bash
smbclient -U "" //<target>/ipc$ -N
```

```bash
rpcclient -U "" <target> -N
```

```bash
enum4linux -a <target>
```

---

## 🧠 OS / Domain / Host info extraction

```bash
enum4linux -o <target>
```

```bash
nmap -p 445 --script smb-os-discovery <target>
```

---

## 🔑 Password policy & domain policy

```bash
rpcclient -U "" <target>
```

Inside:

```bash
getdompwinfo
getusrdompwinfo
```

---

## 📂 LDAP / AD enumeration (kalau domain exposed)

```bash
ldapsearch -x -h <target> -s base
```

```bash
nmap --script ldap-rootdse -p 389 <target>
```

---

## 📡 Full SMB enumeration (Nmap scripts)

```bash
nmap -p 445 --script smb-enum-users <target>
```

```bash
nmap -p 445 --script smb-enum-shares,smb-enum-users,smb-enum-domains <target>
```

```bash
nmap -p 445 --script smb-protocols <target>
```

---

