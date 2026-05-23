# Recon JS denga jsmon

## Membuat & mendaftarkan Ruang Kerja 

```bash
jsmon-cli -cw "post.ch" -key a2a1068e-0fa1-4cfc-996c-372798804e78

jsmon-cli -workspaces -key a2a1068e-0fa1-4cfc-996c-372798804e78
```

## Data Collection

```bash
# Scanning a Single Domain
jsmon-cli -d target.com -key a2a1068e-0fa1-4cfc-996c-372798804e78 -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -silent

# Scanning Multiple Targets
jsmon-cli -f hosts -key a2a1068e-0fa1-4cfc-996c-372798804e78 -wksp e93f225c-18e0-408f-abc6-acc11b26cd11
```

## The Reconnaissance Modules

### Menemukan URL Pengembangan Internal 

```bash
jsmon-cli -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78 -silent -recon "field=localhost page=1"
```

### Mapping Social Media Footprints

```bash
jsmon-cli -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78 -silent -recon "field=socialurls page=1"
```

### Discovering Sensitive Assets

```bash
# Extracting Email Addresses:
jsmon-cli -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78 -silent -recon "field=emails"

# Finding S3 Buckets:
jsmon-cli -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78 -silent -recon "field=s3Buckets"

# Finding Endpoint API
jsmon-cli -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78 -silent -recon "field=apipaths"

# Findign URL Internal
jsmon-cli -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78 -silent -recon "field=internalurls"
```



## Filters & Reverse Search

### Filtering Results

```bash
jsmon-cli -filters "urls=admin" -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78
```

### Reverse Search: Understanding Context

Berikut adalah skenario yang sering terjadi dalam program bug bounty: Anda menemukan endpoint API yang menarik, misalnya... /api/v1/user/deleteNamun, Anda tidak tahu dari file JavaScript mana kode tersebut berasal. Memahami konteksnya, file mana, fitur mana, bagian aplikasi mana, dapat menjadi sangat penting untuk eksploitasi.

Di sinilah Reverse Search berperan. Ini memungkinkan Anda untuk menelusuri kembali dari suatu temuan ke sumbernya: 

```bash
jsmon-cli -rsearch "apipaths=/api/v1/user" -wksp e93f225c-18e0-408f-abc6-acc11b26cd11 -key a2a1068e-0fa1-4cfc-996c-372798804e78
```

Outputnya akan menunjukkan dengan tepat file JavaScript mana yang berisi endpoint spesifik tersebut. Konteks ini dapat mengungkapkan:

  - Apakah endpoint tersebut digunakan dalam konteks terautentikasi atau tidak terautentikasi.
  - Endpoint terkait apa lagi yang ada di file yang sama?
  - Bagaimana endpoint dipanggil dan parameter apa yang diharapkannya
  - Baik ada komentar atau kode debug di dekatnya 

Reverse Search mengubah temuan individual dari titik data yang terisolasi menjadi informasi yang dapat ditindaklanjuti dengan konteks lengkap. 


## The One-Liner Approach

```bash
subfinder -d target.com -silent | httpx -silent | tee urls.txt | xargs -I {} jsmon-cli -d {} -key a2a1068e-0fa1-4cfc-996c-372798804e78 -wksp e93f225c-18e0-408f-abc6-acc11b26cd11
```