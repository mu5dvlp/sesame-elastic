# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`sesame-elastic` — EC2上でELK Stackをホストし、Lambda から Sesame API 経由で定期的に稼働状況を取得・Elasticsearch へ送信する監視基盤。

## 構成

```
sesame-elastic/
├── src/                    # Lambda アプリケーション（クリーンアーキテクチャ）
├── tests/                  # pytest テスト
├── ansible/                # EC2 プロビジョニング（ELK Stack セットアップ）
├── terraform/
│   ├── modules/            # 共通モジュール（VPC, EC2, Lambda, IAM）
│   └── stages/dev/         # dev 環境エントリーポイント
└── pyproject.toml          # Python プロジェクト設定（uv）
```

## ワークフロー

- **変更を加えるたびに必ず git commit すること。**

### インフラ構築

```bash
make tf-apply        # EC2・Lambda 等を作成
make ansible-setup   # EC2 に ELK Stack をインストール（terraform apply 後に実行）
```

### Lambda デプロイ

```bash
make tf-apply        # build → zip → terraform apply を一括実行
```

### ローカル開発

```bash
uv run pytest        # テスト
uv run ruff check src  # Lint
```

## 重要な設定ファイル

- `terraform/stages/dev/terraform.tfvars` — AWS プロファイル・API キー等（gitignore 済み）
- `terraform/stages/dev/terraform.tfvars.example` — tfvars テンプレート
