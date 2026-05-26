# METHODOLOGY RECON PASSIVE & ACTIVE

## Passive Recon

### Identifikasi IP 

```bash
host vfsglobal.com
```

```bash
nslookup vfsglobal.com
```

```bash
traceroute vfsglobal.com
```

```bash
uv run dnsrecon -f -d vfsglobal.com
```

### Indentifikasi WAF / Proxy

```bash
wafw00f vfsglobal.com
```


### DNS Record

```bash
dig vfsglobal.com
```

dig dengan NS

```bash
dig @8.8.8.8 vfsglobal.com
dig @1.1.1.1 vfsglobal.com
```

```bash
dig vfsglobal.com NS
```

Menemapiln semua DNS Record

```bash
dig vfsglobal.com ANY
```

### Mengidentifikasi Penyedia hosting

```bash
whois vfsglobal.com
```

```
https://dnsdumpster.com/
```

### Mengidentifikasi teknologi web

```bash
whatweb vfsglobal.com
```

Extension
```bash
Wappalyzer
```

### mengumpilkan informasi yang berkaitan degan karyawan tertentu

```bash
# Bakal error karena banyak source butuh API key
uv run theHarvester -d vfsglobal.com -b baidu,bevigil,censys,certspotter,chaos,commoncrawl,criminalip,crtsh,dnsdumpster,duckduckgo,fofa,github-code,gitlab,hackertarget,hudsonrock,hunter,hunterhow,leakix,leaklookup,mojeek,netlas,otx,projectdiscovery,rapiddns,robtex,rocketreach,shodan,shodanInternetDB,subdomaincenter,subdomainfinderc99,thc,threatcrowd,urlscan,virustotal,waybackarchive,windvane,yahoo,zoomeye
```

take-over,DNS server lookup

```bash
uv run theHarvester -d vfsglobal.com -t -n 
```

Scan for API endpoints
```bash
uv run theHarvester -d vfsglobal.com -a 
```

### subdomian enumeration

```bash
subfinder -d vfsglobal.com 

echo "vfsglobal.com" | assetfinder --subs-only 
```