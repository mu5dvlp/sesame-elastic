# Application

## 概要

EventBridge から定期的に実行される Lambda。
Sesame API でデバイスの稼働状況を取得し、EC2 上の Elasticsearch に送信する。

## アーキテクチャ（クリーンアーキテクチャ）

```
src/
├── domain/
│   ├── models/device_status.py      # DeviceStatus dataclass
│   └── repositories/
│       ├── device_repository.py     # 抽象: Sesame API からステータス取得
│       └── status_repository.py     # 抽象: Elasticsearch へ保存
├── application/
│   └── use_cases/collect_status.py  # CollectStatusUseCase
├── infrastructure/
│   ├── sesame/client.py             # SesameApiClient (urllib)
│   └── elasticsearch/client.py      # ElasticsearchClient (urllib)
└── presentation/
    └── lambda_function.py           # Lambda ハンドラー
```

## 環境変数（Lambda）

| 変数名              | 説明                        |
|---------------------|-----------------------------|
| `SESAME_API_KEY`    | Sesame API 認証キー         |
| `ELASTICSEARCH_HOST`| EC2 の EIP                  |
| `ELASTICSEARCH_PORT`| デフォルト `9200`           |

## ツール

| 概要         | ツール名 |
|--------------|----------|
| パッケージ管理 | uv      |
| テスト        | pytest  |
| Lint          | ruff    |

## Lambda エントリーポイント

- ハンドラー: `presentation.lambda_function.handler`
- ランタイム: Python 3.12
- zip 化対象: `src/` ディレクトリ全体（`dist/lambda.zip` に出力）
- 外部依存なし（標準ライブラリのみ使用）

## ローカル実行

```bash
SESAME_API_KEY=xxx ELASTICSEARCH_HOST=<EIP> uv run python src/main.py
```

## テスト

```bash
make test
# または
uv run pytest
```
