# sesame-elastic

## 概要

AWS上でELK Stackを使用して、Sesameの稼働状況をモニタリングするツール。

## 必要なアクセス先

### AWS
| 用途 | URL |
|------|-----|
| マネジメントコンソール | https://console.aws.amazon.com/ |
| IAM（アクセスキー・ユーザー管理） | https://console.aws.amazon.com/iam/ |

### Sesame API
| 用途 | URL |
|------|-----|
| API Biz | https://biz.candyhouse.co/ |
| API リファレンス | https://docs.candyhouse.co/ |

## セットアップ

### 1. terraform.tfvars を作成

```bash
cp terraform/stages/dev/terraform.tfvars.example terraform/stages/dev/terraform.tfvars
```

`terraform.tfvars` を編集：
- `aws_profile` — `~/.aws/credentials` のプロファイル名
- `allowed_ssh_cidr` — 自分の IP（`make myip` で確認）
- `sesame_api_key` — [CANDY HOUSE ダッシュボード](https://my.candyhouse.co/) で発行

### 2. インフラ構築

```bash
make tf-init
make tf-apply
```

### 3. EC2 プロビジョニング

```bash
make ansible-setup
```

### 4. 動作確認

```bash
curl http://$(terraform -chdir=terraform/stages/dev output -raw ec2_public_ip):9200
```
