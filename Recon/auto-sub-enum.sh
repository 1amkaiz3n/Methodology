#!/bin/bash

# ============================================================
#  Subdomain Enumeration Script
#  Author  : Bug Hunter
#  Usage   : ./recon.sh <wildcards_file>
# ============================================================

# --- Warna ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Cek argument ---
if [ -z "$1" ]; then
  echo -e "${RED}[!] Usage: $0 <wildcards_file>${NC}"
  exit 1
fi

WILDCARDS="$1"
RESOLVERS=~/belajar/bug_bounty/Tools/resolvers.txt

# --- Cek file wildcards ada ---
if [ ! -f "$WILDCARDS" ]; then
  echo -e "${RED}[!] File '$WILDCARDS' tidak ditemukan!${NC}"
  exit 1
fi

# --- Helper functions ---
info()    { echo -e "${CYAN}[*] $1${NC}"; }
success() { echo -e "${GREEN}[+] $1${NC}"; }
warn()    { echo -e "${YELLOW}[!] $1${NC}"; }
error()   { echo -e "${RED}[-] $1${NC}"; }

run_step() {
  local name="$1"
  shift
  info "Menjalankan: $name"
  "$@"
  if [ $? -eq 0 ]; then
    success "$name selesai"
  else
    warn "$name gagal atau tidak ada output — lanjut ke step berikutnya"
  fi
}

# ============================================================
#  STEP 1 — Passive Recon
# ============================================================
echo ""
echo -e "${BLUE}==============================${NC}"
echo -e "${BLUE}  STEP 1: PASSIVE RECON${NC}"
echo -e "${BLUE}==============================${NC}"

# Subfinder
run_step "Subfinder" bash -c "subfinder -dL '$WILDCARDS' | anew domains"

# Assetfinder
run_step "Assetfinder" bash -c "cat '$WILDCARDS' | assetfinder --subs-only | sort -u | anew domains"

# crt.sh
run_step "crt.sh" bash -c "
  cat '$WILDCARDS' | while read domain; do
    curl -s --max-time 15 \"https://crt.sh/?q=%.\$domain&output=json\" \
      | grep -v '^<' \
      | jq -r '.[].name_value' 2>/dev/null \
      | sed 's/\*\.//g' \
      | tr ',' '\n' \
      | grep -v '^\*' \
      | grep \"\.\$domain$\"
  done | sort -u | anew domains
"

# Chaos
if command -v chaos &>/dev/null; then
  run_step "Chaos" bash -c "chaos -dL '$WILDCARDS' | anew domains"
else
  warn "Chaos tidak terinstall, skip"
fi

# Github-subdomains
if command -v github-subdomains &>/dev/null; then
  run_step "Github-subdomains" bash -c "
    cat '$WILDCARDS' | while read domain; do
      github-subdomains -d \"\$domain\" -raw
    done | grep -v 'https://' | grep -v '^\[' | anew domains
  "
else
  warn "github-subdomains tidak terinstall, skip"
fi

success "Passive recon selesai — total domains: $(wc -l < domains)"

# ============================================================
#  STEP 2 — Active DNS Bruteforce (Alterx + Shuffledns)
# ============================================================
echo ""
echo -e "${BLUE}==============================${NC}"
echo -e "${BLUE}  STEP 2: ACTIVE BRUTEFORCE${NC}"
echo -e "${BLUE}==============================${NC}"

run_step "Alterx" bash -c "cat domains | alterx -o alterx_domains.txt"

if [ -s alterx_domains.txt ]; then
  run_step "Shuffledns resolve" bash -c "
    shuffledns -mode resolve \
      -l alterx_domains.txt \
      -r '$RESOLVERS' \
      -o resolved.txt
  "
else
  warn "alterx_domains.txt kosong, skip shuffledns"
fi

# ============================================================
#  STEP 3 — DNS Validation (dnsx)
# ============================================================
echo ""
echo -e "${BLUE}==============================${NC}"
echo -e "${BLUE}  STEP 3: DNS VALIDATION${NC}"
echo -e "${BLUE}==============================${NC}"

if [ -s resolved.txt ]; then
  run_step "dnsx" bash -c "
    dnsx -l resolved.txt -resp -a -cname -silent | anew valid_domains.txt
  "
  # Merge balik ke domains
  cat valid_domains.txt | awk '{print $1}' | anew domains
  success "Valid domains: $(wc -l < valid_domains.txt)"
else
  warn "resolved.txt kosong, skip dnsx"
fi

# ============================================================
#  STEP 4 — Live Host Check (httpx)
# ============================================================
echo ""
echo -e "${BLUE}==============================${NC}"
echo -e "${BLUE}  STEP 4: LIVE HOST CHECK${NC}"
echo -e "${BLUE}==============================${NC}"

run_step "httpx" bash -c "
  cat domains | httpx -silent \
    -threads 200 \
    -follow-redirects \
    -status-code \
    -title \
    -tech-detect \
    -content-length \
    -web-server \
    -ip \
    -cname \
    -location \
    | tee live_hosts_info
"

# ============================================================
#  SUMMARY
# ============================================================
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  RECON SELESAI!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo -e "${CYAN}  Total domains      : $(wc -l < domains 2>/dev/null || echo 0)${NC}"
echo -e "${CYAN}  Valid domains      : $(wc -l < valid_domains.txt 2>/dev/null || echo 0)${NC}"
echo -e "${CYAN}  Live hosts         : $(wc -l < live_hosts_info 2>/dev/null || echo 0)${NC}"
echo -e "${GREEN}============================================================${NC}"