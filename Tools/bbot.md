# bbot

bbot adalah pemindai serbaguna yang terinspirasi oleh Spiderfoot, dibangun untuk mengotomatiskan kegiatan Pengintaian, Bug Bounty, dan ASM Anda!


## Example Commands

### 1) Subdomain Finder

Passive API sources plus a recursive DNS brute-force with target-specific subdomain mutations.

```bash
# find subdomains of evilcorp.com
bbot -t evilcorp.com -p subdomain-enum

# passive sources only
bbot -t evilcorp.com -p subdomain-enum -rf passive
```

<!-- BBOT SUBDOMAIN-ENUM PRESET EXPANDABLE -->

<details>
<summary><b><code>subdomain-enum.yml</code></b></summary>

```yaml
description: Enumerate subdomains via APIs, brute-force

flags:
  # enable every module with the subdomain-enum flag
  - subdomain-enum

output_modules:
  # output unique subdomains to TXT file
  - subdomains

config:
  dns:
    threads: 25
    brute_threads: 1000
  # put your API keys here
  # modules:
  #   github:
  #     api_key: ""
  #   chaos:
  #     api_key: ""
  #   securitytrails:
  #     api_key: ""

```

</details>

<!-- END BBOT SUBDOMAIN-ENUM PRESET EXPANDABLE -->

BBOT consistently finds 20-50% more subdomains than other tools. The bigger the domain, the bigger the difference. To learn how this is possible, see [How It Works](https://www.blacklanternsecurity.com/bbot/Dev/how_it_works/).



### 2) Web Spider

```bash
# crawl evilcorp.com, extracting emails and other goodies
bbot -t evilcorp.com -p spider
```

<!-- BBOT SPIDER PRESET EXPANDABLE -->

<details>
<summary><b><code>spider.yml</code></b></summary>

```yaml
description: Recursive web spider

modules:
  - httpx

blacklist:
  # Prevent spider from invalidating sessions by logging out
  - "RE:/.*(sign|log)[_-]?out"

config:
  web:
    # how many links to follow in a row
    spider_distance: 2
    # don't follow links whose directory depth is higher than 4
    spider_depth: 4
    # maximum number of links to follow per page
    spider_links_per_page: 25

```

</details>

<!-- END BBOT SPIDER PRESET EXPANDABLE -->

### 3) Email Gatherer

```bash
# quick email enum with free APIs + scraping
bbot -t evilcorp.com -p email-enum

# pair with subdomain enum + web spider for maximum yield
bbot -t evilcorp.com -p email-enum subdomain-enum spider
```

<!-- BBOT EMAIL-ENUM PRESET EXPANDABLE -->

<details>
<summary><b><code>email-enum.yml</code></b></summary>

```yaml
description: Enumerate email addresses from APIs, web crawling, etc.

flags:
  - email-enum

output_modules:
  - emails

```

</details>

<!-- END BBOT EMAIL-ENUM PRESET EXPANDABLE -->

### 4) Web Scanner

```bash
# run a light web scan against www.evilcorp.com
bbot -t www.evilcorp.com -p web-basic

# run a heavy web scan against www.evilcorp.com
bbot -t www.evilcorp.com -p web-thorough
```

<!-- BBOT WEB-BASIC PRESET EXPANDABLE -->

<details>
<summary><b><code>web-basic.yml</code></b></summary>

```yaml
description: Quick web scan

include:
  - iis-shortnames

flags:
  - web-basic

```

</details>

<!-- END BBOT WEB-BASIC PRESET EXPANDABLE -->

<!-- BBOT WEB-THOROUGH PRESET EXPANDABLE -->

<details>
<summary><b><code>web-thorough.yml</code></b></summary>

```yaml
description: Aggressive web scan

include:
  # include the web-basic preset
  - web-basic

flags:
  - web-thorough

```

</details>

<!-- END BBOT WEB-THOROUGH PRESET EXPANDABLE -->

### 5) Everything Everywhere All at Once

```bash
# everything everywhere all at once
bbot -t evilcorp.com -p kitchen-sink --allow-deadly

# roughly equivalent to:
bbot -t evilcorp.com -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly
```
