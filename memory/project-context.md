# Project Context

> このファイルは不変情報を記録する。要件変更時のみ更新すること。
> 全エージェントはセッション開始時にこのファイルを読むこと。

## アプリ概要

**BakusokuMemoApp** — Apple Intelligence を活用したオンデバイス AI メモアプリ

ユーザーが雑然としたテキストを入力し、フォーカスアウトした瞬間に Apple Intelligence がオンデバイスで自動整形・分類する。
**高速起動・即座入力・フォーカスアウト確定** のUXを最優先とする。

### コアユースケース

1. アプリを開く → 入力画面が即座に表示され、キーボードが自動表示される
2. ユーザーが雑然としたテキストを入力する（例: `髭剃りコンタクト液はぶらし`）
3. フォーカスアウト（または完了ボタン）で入力確定
4. バックグラウンドで AI 整形が開始される（アプリを閉じても処理続行）
5. 次にアプリを開くと、整形済みメモが表示されている（例: 買い物リスト形式のチェックボックス付き）

## 技術スタック

| レイヤー    | 技術              | 備考                                                        |
| ----------- | ----------------- | ----------------------------------------------------------- |
| Platform    | iOS 26+           | iPhone 15 Pro 以降必須                                      |
| UI          | SwiftUI           | iOS 26 API 積極利用                                         |
| Persistence | SwiftData         | `@Model`, `@Query`, `ModelContainer`                        |
| AI          | Foundation Models | `SystemLanguageModel`, `LanguageModelSession`, `@Generable` |
| Language    | Swift 6           | strict concurrency mode                                     |

## 絶対制約（全エージェント共通）

- **Apple Intelligence はアプリの前提条件**: フォールバック実装は一切行わない
- `availability` が `.unavailable` の場合: 専用エラー画面（セットアップ誘導）を表示するだけ
- Swift 6 strict concurrency を必ず満たす
- `@Generable` 型で AI 出力を受け取る。raw `String` で受け取らない

## 対応デバイス・OS

- **最小OS**: iOS 26.0
- **対応デバイス**: Apple Intelligence 対応デバイス（iPhone 15 Pro 以降）
- **シミュレーター**: `SystemLanguageModel.default.availability` が `.unavailable(.deviceNotEligible)` になる。AI 整形テストは実機で行う

## ディレクトリ構成

```
BakusokuMemoApp/
├── App/         # BakusokuMemoApp.swift（@main）
├── Models/      # SwiftData @Model クラス（Memo, MemoItem）
├── Views/
│   ├── List/    # MemoListView, MemoRowView
│   ├── Input/   # MemoInputView
│   ├── Detail/  # MemoDetailView, ChecklistView, NoteView
│   └── Error/   # AppleIntelligenceErrorView
├── Features/    # actor MemoFormatter
├── Generable/   # FormattedMemo, MemoType (@Generable)
└── Resources/   # Assets, Localizable.strings
```

## ビルドコマンド

```bash
xcodebuild -scheme BakusokuMemoApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -scheme BakusokuMemoApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```
