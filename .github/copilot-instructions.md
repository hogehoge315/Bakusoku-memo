# BakusokuMemoApp — AI Memo App

## アプリ概要

入力した雑然としたテキストを Apple Intelligence（Foundation Models フレームワーク）がオンデバイスで自動整形・分類するメモアプリ。
**高速起動・即座入力・フォーカスアウトで確定** のUXを最優先とする。

## 絶対ルール（全エージェント共通）

- **Apple Intelligence はアプリの前提条件** ← フォールバック実装は一切行わない
- `SystemLanguageModel.default.availability` が `.unavailable` の場合は、専用エラー画面（セットアップ誘導）を表示するだけでよい。代替ロジックを書かない
- Swift 6 の strict concurrency（`Sendable`, `@MainActor`, `actor`）を必ず満たす
- `@Generable` 型で AI 出力を受け取る。raw `String` で受け取らない

## 技術スタック

| レイヤー    | 技術                                                                             |
| ----------- | -------------------------------------------------------------------------------- |
| Platform    | iOS 26+（iPhone 15 Pro 以降 / Apple Intelligence 対応デバイス必須）              |
| UI          | SwiftUI（iOS 26 API を積極利用）                                                 |
| Persistence | SwiftData（`@Model`, `@Query`, `ModelContainer`）                                |
| AI          | Foundation Models（`SystemLanguageModel`, `LanguageModelSession`, `@Generable`） |
| Language    | Swift 6（strict concurrency mode）                                               |

## ディレクトリ規約

```
BakusokuMemoApp/
├── App/                  # @main, AppDelegate不要
├── Models/               # SwiftData @Model クラス
├── Views/                # SwiftUI View（サブフォルダ: List/, Detail/, Input/, Error/）
├── Features/             # ビジネスロジック（AI整形 Actor 等）
├── Generable/            # @Generable 構造体定義
└── Resources/            # Assets, Localizable.strings
```

## コーディング規約

- `@Model` は `final class` のみ（struct 不可）
- `LanguageModelSession` はリクエストごとに生成（使い捨て）
- `Instructions` は session init 時に設定（動的変更不可）
- SwiftData 操作は `@MainActor` コンテキストで行う
- `ModelContainer` は `@main` の `App` 構造体で1箇所のみ定義
- `@Observable` を ViewModel に使用（`ObservableObject` は使わない）
- View は `@Environment(\.modelContext)` で context を取得
- AI処理中は `.task` modifier + `ProgressView` でハンドリング

## ビルド・テスト

```bash
xcodebuild -scheme BakusokuMemoApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -scheme BakusokuMemoApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

> **注意**: iOS 26 シミュレーターでは `SystemLanguageModel.default.availability` が  
> `.unavailable(.deviceNotEligible)` になる。AI整形のテストは Apple Intelligence 有効な実機で行う。

## Memory システム

セッションをまたぐコンテキストは `memory/` フォルダで管理する。
各エージェントはセッション開始時に `memory/project-context.md` と `memory/progress.md` を読むこと。
設計決定は `memory/decisions.md`、問題は `memory/known-issues.md` に追記する。
