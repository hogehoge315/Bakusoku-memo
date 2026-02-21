# BakusokuMemoApp 全体仕様書

> 生成日: 2026-02-21
> ステータス: Draft
> このファイルはアプリ全体の Source of Truth。変更時は必ず `memory/decisions.md` と整合を確認すること。

---

## 1. 概要

BakusokuMemoApp は、ユーザーが思考の速度で雑然と入力したテキストを Apple Intelligence（Foundation Models）がオンデバイスで自動整形・分類するメモアプリ。「思考の断片を自動で棚に並べるエンジン」をコンセプトに、**高速起動・即座入力・送信で確定** のUXを最優先とする。ユーザーはメモを投げるだけで、AIが裏でスレッドへの分類・統合・Markdown再生成を行う。

---

## 2. UXフロー

### 2.1 画面構成と遷移

```
[入力画面]（index 0 / デフォルト・起動直後）
  ↕ 右スワイプ
[スレッド一覧]（index 1）
  ↕ タップ
[スレッド詳細]（NavigationStack push）

（詳細 → 左スワイプ → 一覧 → 左スワイプ → 入力画面）
```

実装: `TabView` + `PageTabViewStyle` によるページング（ADR-007）。

---

### 2.2 入力画面（InputView）— デフォルト画面

#### 起動時

1. アプリ起動直後、入力画面が表示される
2. キーボードが自動表示される（`@FocusState` で即フォーカス）

#### 入力中

3. 入力テキストが **2秒以上経過 かつ 10文字以上** になると：
   - `actor ThreadFormatter` がバブル候補（最大3件）を非同期生成
   - 入力フィールド上部にバブルUIとして表示
4. バブル選択は任意（未選択でも送信可能）

#### 送信

5. 送信ボタン（または確定操作）でメモ確定
6. 入力フォームをリセット（テキスト消去・バブル消去）
7. トースト1: 「○○スレッドに追加中…」＋「戻す」ボタン（3秒表示）
8. トースト2: 「○○スレッドに追加しました」（トースト1消滅後）
9. 「戻す」ボタン押下 → `PendingMemo` ステータスを保留に変更、トリアージキューへ

#### バックグラウンドAI処理

10. バックグラウンドで `actor ThreadFormatter` がスレッドへの分類・統合・Markdown再生成を行う
11. アプリを閉じても処理が継続する

#### 未分類バナー

12. 保留中の `PendingMemo` が1件以上ある場合、上部に「未分類メモ N件」バナーを表示
13. バナータップ → 保留トリアージシートを表示

---

### 2.3 保留トリアージシート（TriageSheetView）

1. ボトムシートとして表示
2. 1枚カード形式でPendingMemoを順番に提示
   - AI候補3件（既存スレッド）＋「新規スレッド作成」を表示
3. ジェスチャー操作:
   - **右スワイプ** → 登録（選択したスレッドへ統合）→ LLM処理 → 次カードへ自動進行
   - **上スワイプ** → スキップ（後回し）→ 次カードへ自動進行
   - **左スワイプ** → 廃棄（`PendingMemo` 削除）→ 次カードへ自動進行
4. 全カード消化でシート自動終了

---

### 2.4 スレッド一覧（ThreadListView）

1. 上部に検索バーを常時表示
2. スレッドをLINEトーク風リスト表示:
   - スレッドタイトル
   - 右端に更新日時
   - Markdownプレビュー（先頭N文字）
3. 長押し → フルMarkdownプレビュー展開
4. 🔒アイコン（タップでロック/解除トグル）
   - ロック中: AI自動更新禁止（アイコン表示・ユーザー編集は可能）
5. LLM処理中のスレッド: スピナー表示 ＋ 編集ボタン非活性
6. 左スワイプ → 削除（確認ダイアログあり）
7. 左上「選択」ボタン → チェックボックス表示 → 一括削除
8. 未分類メモ N件バナー（スレッド一覧上部）→ タップでトリアージシート

---

### 2.5 スレッド詳細（ThreadDetailView）

1. デフォルト: Markdownプレビューモード（GitHub Markdown風レンダリング）
2. 編集ボタンタップ → 編集モード（プレーンテキスト編集）
3. タイトル: ユーザー編集可・AI変更禁止（新規スレッド作成時のみAIが命名）
4. ロック中（`Thread.isLocked == true`）: AI自動更新禁止（ユーザー編集は可能）
5. LLM処理中（`Thread.isProcessing == true`）: 編集ボタン非活性
6. 右下にAI指示バブルアイコン:
   - タップ → テキスト入力欄 ＋ 送信ボタンを展開
   - テキスト送信 → LLM処理（編集ロック）→ Markdown更新
   - AI指示ログとして `ThreadItem`（`itemType: .aiInstruction`）に記録
7. 元メモ履歴セクション:
   - デフォルト: 畳まれた状態
   - タップで展開
   - メモ追加・AI指示のたびにログ追記
   - 各 `ThreadItem` はタイムスタンプ付き

---

### 2.6 Apple Intelligence エラー画面（AppleIntelligenceErrorView）

- `SystemLanguageModel.default.availability` が `.unavailable` の場合に表示
- セットアップ誘導メッセージを表示（設定アプリへ誘導など）
- 代替ロジック・フォールバック処理は一切なし（ADR-003）

---

## 3. 機能要件

### 3.1 必須

#### 入力・送信

- [ ] 起動直後にキーボードが自動表示される
- [ ] 入力テキストが2秒以上経過 かつ 10文字以上でバブル候補（最大3件）を表示する
- [ ] バブル候補は既存スレッド名から生成される
- [ ] 送信ボタンでメモを確定し、フォームをリセットする
- [ ] 送信後トースト（2段階: 処理中 → 完了）を表示する
- [ ] 「戻す」ボタンで保留ステータスに変更できる
- [ ] バックグラウンドでAI処理を継続できる

#### スレッド管理

- [ ] スレッドの作成・更新・削除ができる
- [ ] スレッドのロック/解除トグルができる（ロック中はAI自動更新禁止）
- [ ] スレッド一覧で検索ができる
- [ ] スレッドをMarkdownプレビューモードで表示する
- [ ] スレッドを編集モードで直接編集できる
- [ ] LLM処理中のスレッドは編集不可とする

#### AI機能

- [ ] 入力テキストから既存スレッドへのバブル候補3件を生成する（`ThreadSuggestion`）
- [ ] 新規メモをスレッドに統合し、Markdownを再生成する（`FormattedThread`）
- [ ] スレッド詳細のAI指示に従いMarkdownを更新する（`FormattedThread`）
- [ ] `GenerationError.exceededContextWindowSize` 発生時はUIでエラー通知する

#### トリアージ

- [ ] 保留中PendingMemoをカード形式で一覧表示する
- [ ] 右スワイプ（登録）・上スワイプ（スキップ）・左スワイプ（廃棄）が機能する
- [ ] 全カード消化でシートが自動終了する

#### エラーハンドリング

- [ ] Apple Intelligence 非対応時は `AppleIntelligenceErrorView` を表示する

### 3.2 対象外（スコープ外）

- Apple Intelligence 非対応デバイス向けのフォールバック処理（ルールベース整形・外部API）
- iCloud同期・クロスデバイス同期
- メモの共有・エクスポート機能
- Push通知
- ウィジェット（ホーム画面・ロック画面）
- iPadOS・macOS対応
- Siriショートカット連携

---

## 4. データ要件

### 4.1 データモデル（ADR-006）

#### `Thread`（スレッド）

| プロパティ        | 型             | 説明                                            |
| ----------------- | -------------- | ----------------------------------------------- |
| `id`              | `UUID`         | 一意識別子（PrimaryKey）                        |
| `title`           | `String`       | スレッドタイトル（ユーザー編集可・AI変更禁止）  |
| `markdownContent` | `String`       | AI生成Markdownコンテンツ（Source of Truth）     |
| `isLocked`        | `Bool`         | ロック中はAI自動更新禁止（デフォルト: `false`） |
| `isProcessing`    | `Bool`         | LLM処理中フラグ（処理中は編集不可）             |
| `updatedAt`       | `Date`         | 最終更新日時                                    |
| `items`           | `[ThreadItem]` | 元メモ履歴・AI指示ログ（リレーション）          |

#### `ThreadItem`（元メモ履歴・AI指示ログ）

| プロパティ  | 型         | 説明                                               |
| ----------- | ---------- | -------------------------------------------------- |
| `id`        | `UUID`     | 一意識別子                                         |
| `threadId`  | `UUID`     | 所属スレッドID                                     |
| `rawText`   | `String`   | 元テキスト（メモ本文またはAI指示文）               |
| `itemType`  | `ItemType` | `.memo`（元メモ）または `.aiInstruction`（AI指示） |
| `createdAt` | `Date`     | 追加日時                                           |

```swift
enum ItemType: String, Codable {
    case memo
    case aiInstruction
}
```

#### `PendingMemo`（保留メモ）

| プロパティ  | 型       | 説明       |
| ----------- | -------- | ---------- |
| `id`        | `UUID`   | 一意識別子 |
| `rawText`   | `String` | 元テキスト |
| `createdAt` | `Date`   | 作成日時   |

### 4.2 永続化

- SwiftData（`@Model`, `@Query`, `ModelContainer`）（ADR-002）
- `ModelContainer` は `@main` の `App` 構造体で1箇所のみ定義
- SwiftData 操作はすべて `@MainActor` コンテキストで行う
- `actor ThreadFormatter` では `@Model` インスタンスを直接保持しない。`UUID` 等のプリミティブ値のみをactor境界を越えて渡す（ISSUE-004対応）

---

## 5. AI要件

### 5.1 前提

- Foundation Models フレームワーク使用（ADR-004）
- `LanguageModelSession` はリクエストごとに生成（使い捨て）
- `Instructions` は session init 時に設定（動的変更不可）
- raw `String` で受け取らない。必ず `@Generable` 型で受け取る

### 5.2 `ThreadSuggestion`（バブル候補・トリアージ候補）

```
入力: ユーザー入力テキスト + 既存スレッドタイトル一覧
出力: @Generable ThreadSuggestion
役割: 入力テキストに最も関連する既存スレッド候補（最大3件）を返す
```

**`@Generable` 型定義（概要）:**

```swift
@Generable
struct ThreadSuggestion {
    @Guide(description: "関連スレッド候補（最大3件）のタイトル一覧")
    var suggestions: [String]
}
```

**システムプロンプト方針:**

- 入力テキストの意味・カテゴリと既存スレッドタイトルの関連度で候補を絞る
- 該当なしの場合は空配列を返す
- 新規スレッド作成が適切な場合は空配列で返し、UIが「新規作成」を提案する

**トリガー条件:** 入力テキストが2秒以上経過 かつ 10文字以上

### 5.3 `FormattedThread`（Markdown再生成）

```
入力: 既存スレッドのMarkdown全文 + 新規メモテキスト（またはAI指示テキスト）
出力: @Generable FormattedThread
役割: 既存Markdownに新メモを統合した新しいMarkdown全文を返す（フル再生成方式・ADR-008）
```

**`@Generable` 型定義（概要）:**

```swift
@Generable
struct FormattedThread {
    @Guide(description: "統合後のMarkdown全文")
    var markdownContent: String

    @Guide(description: "スレッドタイトル（新規作成時のみ。既存スレッドの場合は空文字）")
    var title: String
}
```

**システムプロンプト方針（フル再生成）:**

- 変更最小化を優先する（既存の文体・セクション構成を維持）
- 新情報はセクション単位で追記する（大幅な書き換えは最終手段）
- タイトルは新規スレッド作成時のみ生成する（既存スレッドの場合は空文字）
- Markdownフォーマット（見出し・リスト・コードブロック等）を活用する

### 5.4 AI指示処理

- 入力: 既存Markdown全文 + ユーザーが入力したAI指示テキスト
- 出力: `FormattedThread`（上記と同一型）
- `ThreadItem`（`itemType: .aiInstruction`）として履歴に記録する

### 5.5 エラーハンドリング

| エラー                                                     | 対処                                                             |
| ---------------------------------------------------------- | ---------------------------------------------------------------- |
| `SystemLanguageModel.default.availability == .unavailable` | `AppleIntelligenceErrorView` を表示。代替処理なし                |
| `GenerationError.exceededContextWindowSize`                | UIで「テキストが長すぎます」を通知。テキスト分割再試行は書かない |

### 5.6 パフォーマンス

- アプリ起動時に `SystemLanguageModel` の `prewarm` を実行する
- `actor ThreadFormatter` でAI処理を隔離し、メインスレッドをブロックしない（ADR-005）

---

## 6. 受け入れ条件

### 起動・入力

- [ ] iPhone 15 Pro（Apple Intelligence有効）でアプリ起動から入力可能状態まで 300ms 以内（Instruments App Launch計測）
- [ ] 起動直後にキーボードが自動表示される
- [ ] テキスト入力から2秒後（10文字以上）にバブル候補3件以内が表示される
- [ ] 送信ボタンタップ後にフォームがリセットされる

### AI機能

- [ ] 実機（Apple Intelligence有効）でバブル候補が既存スレッドから適切に選ばれる
- [ ] 実機（Apple Intelligence有効）でメモ送信後にスレッドのMarkdownが更新される
- [ ] AI指示テキスト送信後にMarkdownが指示に従い更新される
- [ ] コンテキストウィンドウ超過時にユーザーへエラー通知が表示される

### スレッド管理

- [ ] スレッドのロック中はAI更新がスキップされ、`markdownContent` が変更されない
- [ ] LLM処理中のスレッドで編集ボタンが非活性になる
- [ ] スレッド一覧の検索で部分一致検索ができる
- [ ] 左スワイプ削除 → 確認後にスレッドが削除される
- [ ] 一括削除でチェックしたスレッドがすべて削除される

### トリアージ

- [ ] 保留メモN件バナーに正確な件数が表示される
- [ ] 右スワイプで選択スレッドへの統合が開始される
- [ ] 左スワイプでPendingMemoが削除される
- [ ] 全カード消化でシートが閉じる

### エラー

- [ ] iOS 26 シミュレーターで起動すると `AppleIntelligenceErrorView` が表示される
- [ ] `AppleIntelligenceErrorView` にフォールバック処理・代替ボタンが存在しない

### 並行処理・安全性

- [ ] Swift 6 strict concurrency で警告・エラーなしビルドが通る
- [ ] `actor ThreadFormatter` 内で `@Model` インスタンスの直接保持がない
- [ ] SwiftData書き込みがすべて `@MainActor` コンテキストで行われる

---

## 7. 関連ADR

| ADR     | 内容                                             |
| ------- | ------------------------------------------------ |
| ADR-001 | UIフレームワーク — SwiftUI採用                   |
| ADR-002 | 永続化 — SwiftData採用                           |
| ADR-003 | AI機能 — フォールバック実装しない                |
| ADR-004 | AIフレームワーク — Foundation Models採用         |
| ADR-005 | 並行処理 — `actor ThreadFormatter`               |
| ADR-006 | データモデル — Thread / ThreadItem / PendingMemo |
| ADR-007 | ナビゲーション — 左右スワイプによるページング    |
| ADR-008 | Markdown表示 — フル再生成方式                    |

---

## 8. 制約・注意事項

### Swift 6 / 並行処理

- `@MainActor` コンテキスト外での SwiftData 操作は禁止
- `actor ThreadFormatter` では `UUID` 等プリミティブ値のみをactor境界越えで渡す（`@Model` インスタンスは渡さない）
- `@Observable` を ViewModel に使用（`ObservableObject` は不使用）

### Apple Intelligence / Foundation Models

- **iOS 26.0+ 必須**（iPhone 15 Pro 以降）
- `@Generable` マクロは iOS 26 以上でのみ動作（`@available` ガード不要: 全ターゲットが iOS 26+）
- `LanguageModelSession` はリクエストごとに生成・使い捨て
- `Instructions` は session init 時に固定（動的変更不可）
- iOS 26 シミュレーターでは AI機能のテスト不可（ISSUE-001）

### SwiftData

- `@Model` は `final class` のみ（`struct` 不可）
- `ModelContainer` は `@main` の `App` 構造体で1箇所のみ定義
- View は `@Environment(\.modelContext)` で context を取得

### エラーハンドリング戦略

- `GenerationError.exceededContextWindowSize` → UIエラー通知のみ。分割再試行は実装しない（ISSUE-002）
- `availability == .unavailable` → `AppleIntelligenceErrorView` のみ。代替ロジックなし（ADR-003）

---

## 9. ディレクトリ構成

```
BakusokuMemoApp/
├── App/
│   └── BakusokuMemoApp.swift           # @main, ModelContainer定義
├── Models/
│   ├── Thread.swift                    # @Model final class
│   ├── ThreadItem.swift                # @Model final class
│   └── PendingMemo.swift               # @Model final class
├── Views/
│   ├── RootView.swift                  # TabView + PageTabViewStyle
│   ├── Input/
│   │   └── InputView.swift             # デフォルト画面
│   ├── List/
│   │   ├── ThreadListView.swift
│   │   └── ThreadRowView.swift
│   ├── Detail/
│   │   ├── ThreadDetailView.swift
│   │   └── MemoHistoryView.swift
│   ├── Triage/
│   │   ├── TriageSheetView.swift
│   │   └── TriageCardView.swift
│   └── Error/
│       └── AppleIntelligenceErrorView.swift
├── Features/
│   └── ThreadFormatter.swift           # actor ThreadFormatter
├── Generable/
│   ├── ThreadSuggestion.swift          # @Generable
│   └── FormattedThread.swift           # @Generable
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

---

## 10. 実装フェーズ（progress.md との対応）

| フェーズ | 内容                                                           | 状態      |
| -------- | -------------------------------------------------------------- | --------- |
| Phase 0  | AI駆動開発インフラ（agents / instructions / prompts / memory） | ✅ 完了   |
| Phase 1  | Xcodeプロジェクト初期化・ディレクトリ構成                      | ⬜ 未着手 |
| Phase 2  | データモデル（Thread / ThreadItem / PendingMemo）              | ⬜ 未着手 |
| Phase 3  | @Generable構造体（ThreadSuggestion / FormattedThread）         | ⬜ 未着手 |
| Phase 4  | AI整形機能（actor ThreadFormatter）                            | ⬜ 未着手 |
| Phase 5  | SwiftUI Views（全画面）                                        | ⬜ 未着手 |
| Phase 6  | 統合・品質（E2Eフロー結合・実機テスト・Instruments計測）       | ⬜ 未着手 |
