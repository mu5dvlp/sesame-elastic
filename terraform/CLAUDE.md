# Infrastructure

## 概要

EC2上でELK Stack（Elasticsearch 8.x + Kibana 8.x）をホストし、Lambda から定期的に Sesame デバイスの稼働状況を Elasticsearch に送信する。

## 構成

```
terraform/
├── modules/          # 再利用可能なモジュール（VPC, EC2, Lambda, IAM）
└── stages/dev/       # dev 環境エントリーポイント
```

## 設計方針

- **リージョン**: ap-northeast-1（東京）
- **EC2 アクセス**: SSH + SSM Session Manager
- **Lambda**: VPC 外配置（NAT Gateway コスト削減）
- **Elasticsearch 9200**: SG で `0.0.0.0/0` 許可（Lambda の IP が不定なため）
- **セキュリティ**: dev では `xpack.security.enabled=false`（prod では要有効化）

## 操作手順

```bash
cd terraform/stages/dev
terraform init
terraform validate
terraform plan
terraform apply
```

`terraform.tfvars` の `allowed_ssh_cidr` を自身の IP に設定してから apply すること。
