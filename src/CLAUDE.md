# Application

## 概要

Eventbridgeから、定期的に実行される。

Sesame APIを使用して、稼働状況についてをEC2のElasticsearchに送信する。

## アーキテクチャ

厳密なクリーンアーキテクチャを使用して、アプリケーションを構成。

- Domain：ドメインモデルなど業務ロジックを定義
- Application：ユースケースなどを定義
- Infrastructure：具体的な実装を定義
- Presentation：アプリ境界を定義

## ツール

|概要|ツール名|
|---|---|
|パッケージ管理|uv|
|テスト|Pytest|
|Lint|ruff|

## Lambda エントリーポイント

- ハンドラー: `presentation.lambda_function.handler`
- ランタイム: Python 3.12
- zip 化対象: `src/` ディレクトリ全体（`dist/lambda.zip` に出力）
