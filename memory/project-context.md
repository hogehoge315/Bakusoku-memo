# Project Context

> このファイルは不変情報を記録する。要件変更時のみ更新すること。
> 全エージェントはセッション開始時にこのファイルを読むこと。

## アプリ概要

**BakusokuMemoApp** — Apple Intelligence を活用したオンデバイス AI メモアプリ

「思考の断片を自動で棚に並べるエンジン」。ユーザーは思考の速度でメモを投げるだけ。AIが裏でスレッドへの分類・構造化・統合を行う。
**高速起動・即座入力・送信で確定** のUXを最優先とする。

### コアユースケース

1. アプリを開く → 入力画面が即座に表示され、キーボードが自動表示される
2. ユーザーが雑然としたテキストを入力する（例: `髭剃りコンタクト液はぶらし`）
3. 入力中、2秒 + 10文字以上でバブル候補（最大3件）が自動表示される
4. 送信ボタンで確定（バブル選択は任意）→ フォームリセット
5. バックグラウンドで AI がスレッドへの分類・統合・Markdown再生成を行う（アプリを閉じても続行）
6. 次にアプリを開くと、スレッドのMarkdownサマリーが更新されている

### UXフロー全体

```
[入力画面]（デフォルト・起動直後）
  ↕ 右スワイプ
[スレッド一覧]
  ↕ タップ
[スレッド詳細]
（詳細 → 左スワイプ → 一覧 → 左スワイプ → 入力画面）
```

#### 入力画面

- キーボード自動ON
- 2秒 + 10文字以上でバブル候補（最大3件）表示
- 送信ボタンで確定 → フォームリセット
- 未分類メモ N件バナー（保留ありのとき）→ タップでトリアージシート

#### 送信後フィードバック

- トースト1: 「○○スレッドに追加中…」+ 「戻す」ボタン（3秒）
- トースト2: 「○○スレッドに追加しました」
- 「戻す」押下 → 保留ステータスへ

#### 保留トリアージシート（ボトムシート）

- 1枚カード形式（AI候補3件 + 新規作成）
- 右スワイプ → 登録 → LLM処理 → 次カード自動進行
- 上スワイプ → スキップ（後回し）→ 次カード
- 左スワイプ → 廃棄 → 次カード
- 全カード消化でシート自動終了

#### スレッド一覧

- 上部に検索バー（常に表示）
- LINEトーク風（タイトル + 右端に更新日時 + Markdownプレビュー）
- 長押しで全文展開
- 🔒アイコン（タップでロック/解除トグル）→ ロック中はAI自動更新禁止
- LLM処理中のスレッドはスピナー表示 + 編集不可
- 左スワイプで削除
- 左上「選択」→ チェックボックス一括削除
- 未分類メモ N件バナー → タップでトリアージシート

#### スレッド詳細

- デフォルト: Markdownプレビューモード（GitHub風）
- 編集ボタンタップ → 編集モード
- タイトル: ユーザー編集可・AI変更禁止（新規作成時のみAIが命名）
- ロック中はAI自動更新禁止（ユーザー編集は可能）
- LLM処理中は編集ボタン非活性
- 右下にAI指示バブルアイコン → タップで入力欄＋送信ボタン展開
  → テキスト送信 → LLM処理（編集ロック）→ Markdown更新
- 元メモ履歴（デフォルト畳まれ・タップで展開・更新ごとにログ追記）
  - AI指示ログも「AI指示: [内容]」として記録される

#### スレッド統合（AI処理）

- 既存Markdown全文 + 新メモ → LLMへ
- システムプロンプト: 「変更最小化・セクション単位更新。大幅変更が必要な場合のみ全体再構成」
- 生成時間はかかってもOK（UX的に許容済み）

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
├── Models/      # SwiftData @Model クラス（Thread, ThreadItem, PendingMemo）
├── Views/
│   ├── Input/   # InputView（デフォルト画面）
│   ├── List/    # ThreadListView, ThreadRowView
│   ├── Detail/  # ThreadDetailView, MemoHistoryView
│   ├── Triage/  # TriageSheetView, TriageCardView
│   └── Error/   # AppleIntelligenceErrorView
├── Features/    # actor ThreadFormatter
├── Generable/   # ThreadSuggestion, FormattedThread (@Generable)
└── Resources/   # Assets, Localizable.strings
```

## ビルドコマンド

```bash
xcodebuild -scheme BakusokuMemoApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -scheme BakusokuMemoApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```
