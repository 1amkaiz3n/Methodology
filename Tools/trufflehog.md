# TruffleHog 

rahasia yang paling ampuh TruffleHog adalah alat penemuan, klasifikasi, validasi, dan analisis . Dalam konteks ini, rahasia mengacu pada kredensial yang digunakan mesin untuk mengautentikasi dirinya sendiri ke mesin lain. Ini termasuk kunci API, kata sandi basis data, kunci enkripsi pribadi, dan banyak lagi. 

## Discovery 🔍

TruffleHog dapat mencari rahasia di banyak tempat termasuk Git, obrolan, wiki, log, platform pengujian API, penyimpanan objek, sistem file, dan banyak lagi.

## Classification 📁

TruffleHog mengklasifikasikan lebih dari 800 jenis rahasia, memetakannya kembali ke identitas spesifik yang dimilikinya. Apakah itu rahasia AWS? Rahasia Stripe? Rahasia Cloudflare? Kata sandi Postgres? Kunci privat SSL? Terkadang sulit untuk mengetahuinya hanya dengan melihatnya, jadi TruffleHog mengklasifikasikan semua yang ditemukannya. 
classifies everything it finds.

## Validation ✅

Untuk setiap rahasia yang dapat diklasifikasikan oleh TruffleHog, ia juga dapat masuk untuk memastikan apakah rahasia tersebut aktif atau tidak. Langkah ini sangat penting untuk mengetahui apakah ada bahaya aktif saat ini atau tidak. 

## Analysis 🔬

Untuk 20 jenis kredensial yang paling sering bocor, alih-alih mengirim satu permintaan untuk memeriksa apakah rahasia tersebut dapat digunakan untuk masuk, TruffleHog dapat mengirim banyak permintaan untuk mempelajari semua hal tentang rahasia tersebut. Siapa yang membuatnya? Sumber daya apa yang dapat diaksesnya? Izin apa yang dimilikinya pada sumber daya tersebut? 


# :tv: Demo

![GitHub scanning demo](https://storage.googleapis.com/truffle-demos/non-interactive.svg)

# :rocket: Quick Start

## 1: Scan a repo for only verified secrets

Command:

```bash
trufflehog git https://github.com/trufflesecurity/test_keys --results=verified
```

Expected output:

```
🐷🔑🐷  TruffleHog. Unearth your secrets. 🐷🔑🐷

Found verified result 🐷🔑
Detector Type: AWS
Decoder Type: PLAIN
Raw result: AKIAYVP4CIPPERUVIFXG
Line: 4
Commit: fbc14303ffbf8fb1c2c1914e8dda7d0121633aca
File: keys
Email: counter <counter@counters-MacBook-Air.local>
Repository: https://github.com/trufflesecurity/test_keys
Timestamp: 2022-06-16 10:17:40 -0700 PDT
...
```

## 2: Scan a GitHub Org for only verified secrets

```bash
trufflehog github --org=trufflesecurity --results=verified
```

## 3: Scan a GitHub Repo for only verified secrets and get JSON output

Command:

```bash
trufflehog git https://github.com/trufflesecurity/test_keys --results=verified --json
```

Expected output:

```
{"SourceMetadata":{"Data":{"Git":{"commit":"fbc14303ffbf8fb1c2c1914e8dda7d0121633aca","file":"keys","email":"counter \u003ccounter@counters-MacBook-Air.local\u003e","repository":"https://github.com/trufflesecurity/test_keys","timestamp":"2022-06-16 10:17:40 -0700 PDT","line":4}}},"SourceID":0,"SourceType":16,"SourceName":"trufflehog - git","DetectorType":2,"DetectorName":"AWS","DecoderName":"PLAIN","Verified":true,"Raw":"AKIAYVP4CIPPERUVIFXG","Redacted":"AKIAYVP4CIPPERUVIFXG","ExtraData":{"account":"595918472158","arn":"arn:aws:iam::595918472158:user/canarytokens.com@@mirux23ppyky6hx3l6vclmhnj","user_id":"AIDAYVP4CIPPJ5M54LRCY"},"StructuredData":null}
...
```

## 4: Scan a GitHub Repo + its Issues and Pull Requests

```bash
trufflehog github --repo=https://github.com/trufflesecurity/test_keys --issue-comments --pr-comments
```

## 5: Scan an S3 bucket for high-confidence results (verified + unknown)

```bash
trufflehog s3 --bucket=<bucket name> --results=verified,unknown
```

## 6: Scan S3 buckets using IAM Roles

```bash
trufflehog s3 --role-arn=<iam role arn>
```

## 7: Scan a Github Repo using SSH authentication in Docker

```bash
docker run --rm -v "$HOME/.ssh:/root/.ssh:ro" trufflesecurity/trufflehog:latest git ssh://github.com/trufflesecurity/test_keys
```

## 8: Scan individual files or directories

```bash
trufflehog filesystem path/to/file1.txt path/to/file2.txt path/to/dir
```

## 9: Scan a local git repo

Clone the git repo. For example [test keys](git@github.com:trufflesecurity/test_keys.git) repo.
```bash
git clone git@github.com:trufflesecurity/test_keys.git
```

Run trufflehog from the parent directory (outside the git repo).
```bash
trufflehog git file://test_keys --results=verified,unknown
```

To guard against malicious git configs in local scanning (see CVE-2025-41390), TruffleHog clones local git repositories to a temporary directory prior to scanning. This follows [Git's security best practices](https://git-scm.com/docs/git#_security). If you want to specify a custom path to clone the repository to (instead of tmp), you can use the `--clone-path` flag. If you'd like to skip the local cloning process and scan the repository directly (only do this for trusted repos), you can use the `--trust-local-git-config` flag.

## 10: Scan GCS buckets for only verified secrets

```bash
trufflehog gcs --project-id=<project-ID> --cloud-environment --results=verified
```

## 11: Scan a Docker image for only verified secrets

Use the `--image` flag multiple times to scan multiple images.

```bash
# to scan from a remote registry
trufflehog docker --image trufflesecurity/secrets --results=verified

# to scan from the local docker daemon
trufflehog docker --image docker://new_image:tag --results=verified

# to scan from an image saved as a tarball
trufflehog docker --image file://path_to_image.tar --results=verified
```

## 12: Scan in CI

Set the `--since-commit` flag to your default branch that people merge into (ex: "main"). Set the `--branch` flag to your PR's branch name (ex: "feature-1"). Depending on the CI/CD platform you use, this value can be pulled in dynamically (ex: [CIRCLE_BRANCH in Circle CI](https://circleci.com/docs/variables/) and [TRAVIS_PULL_REQUEST_BRANCH in Travis CI](https://docs.travis-ci.com/user/environment-variables/)). If the repo is cloned and the target branch is already checked out during the CI/CD workflow, then `--branch HEAD` should be sufficient. The `--fail` flag will return an 183 error code if valid credentials are found.

```bash
trufflehog git file://. --since-commit main --branch feature-1 --results=verified,unknown --fail
```

## 13: Scan a Postman workspace

Use the `--workspace-id`, `--collection-id`, `--environment` flags multiple times to scan multiple targets.

```bash
trufflehog postman --token=<postman api token> --workspace-id=<workspace id>
```

## 14: Scan a Jenkins server

```bash
trufflehog jenkins --url https://jenkins.example.com --username admin --password admin
```

## 15: Scan an Elasticsearch server

### Scan a Local Cluster

There are two ways to authenticate to a local cluster with TruffleHog: (1) username and password, (2) service token.

#### Connect to a local cluster with username and password

```bash
trufflehog elasticsearch --nodes 192.168.14.3 192.168.14.4 --username truffle --password hog
```

#### Connect to a local cluster with a service token

```bash
trufflehog elasticsearch --nodes 192.168.14.3 192.168.14.4 --service-token ‘AAEWVaWM...Rva2VuaSDZ’
```

### Scan an Elastic Cloud Cluster

To scan a cluster on Elastic Cloud, you’ll need a Cloud ID and API key.

```bash
trufflehog elasticsearch \
  --cloud-id 'search-prod:dXMtY2Vx...YjM1ODNlOWFiZGRlNjI0NA==' \
  --api-key 'MlVtVjBZ...ZSYlduYnF1djh3NG5FQQ=='
```

## 16. Scan a GitHub Repository for Cross Fork Object References and Deleted Commits

The following command will enumerate deleted and hidden commits on a GitHub repository and then scan them for secrets. This is an alpha release feature.

```bash
trufflehog github-experimental --repo https://github.com/<USER>/<REPO>.git --object-discovery
```

In addition to the normal TruffleHog output, the `--object-discovery` flag creates two files in a new `$HOME/.trufflehog` directory: `valid_hidden.txt` and `invalid.txt`. These are used to track state during commit enumeration, as well as to provide users with a complete list of all hidden and deleted commits (`valid_hidden.txt`). If you'd like to automatically remove these files after scanning, please add the flag `--delete-cached-data`.

**Note**: Enumerating all valid commits on a repository using this method takes between 20 minutes and a few hours, depending on the size of your repository. We added a progress bar to keep you updated on how long the enumeration will take. The actual secret scanning runs extremely fast.

For more information on Cross Fork Object References, please [read our blog post](https://trufflesecurity.com/blog/anyone-can-access-deleted-and-private-repo-data-github).

## 17. Scan Hugging Face

### Scan a Hugging Face Model, Dataset or Space

```bash
trufflehog huggingface --model <model_id> --space <space_id> --dataset <dataset_id>
```

### Scan all Models, Datasets and Spaces belonging to a Hugging Face Organization or User

```bash
trufflehog huggingface --org <orgname> --user <username>
```

(Optionally) When scanning an organization or user, you can skip an entire class of resources with `--skip-models`, `--skip-datasets`, `--skip-spaces` OR a particular resource with `--ignore-models <model_id>`, `--ignore-datasets <dataset_id>`, `--ignore-spaces <space_id>`.

### Scan Discussion and PR Comments

```bash
trufflehog huggingface --model <model_id> --include-discussions --include-prs
```

## 18. Scan stdin Input

```bash
aws s3 cp s3://example/gzipped/data.gz - | gunzip -c | trufflehog stdin
```
