# Application

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
