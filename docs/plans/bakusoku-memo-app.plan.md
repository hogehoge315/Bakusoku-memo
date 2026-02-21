# BakusokuMemoApp 実装計画

> 生成日: 2026-02-21
> 入力Spec: docs/specs/bakusoku-memo-app.spec.md
> ステータス: Draft

---

## 1. 概要

ユーザーが雑然と入力したテキストを Apple Intelligence がオンデバイスで自動整形・スレッド分類するメモアプリを、Phase 1（Xcode初期化）から Phase 6（統合・品質）まで順次実装する。

---

## 2. 影響ファイル

### 新規作成

**App**

- `BakusokuMemoApp/App/BakusokuMemoApp.swift` — `@main` App構造体・`ModelContainer` 定義・`prewarm` 実行

**Models**

- `BakusokuMemoApp/Models/Thread.swift` — `@Model final class Thread`
- `BakusokuMemoApp/Models/ThreadItem.swift` — `@Model final class ThreadItem`・`ItemType` enum
- `BakusokuMemoApp/Models/PendingMemo.swift` — `@Model final class PendingMemo`

**Generable**

- `BakusokuMemoApp/Generable/ThreadSuggestion.swift` — `@Generable struct ThreadSuggestion`
- `BakusokuMemoApp/Generable/FormattedThread.swift` — `@Generable struct FormattedThread`

**Features**

- `BakusokuMemoApp/Features/ThreadFormatter.swift` — `actor ThreadFormatter`（バブル候補生成・スレッド統合・AI指示処理）

**Views**

- `BakusokuMemoApp/Views/RootView.swift` — `TabView` + `PageTabViewStyle`
- `BakusokuMemoApp/Views/Error/AppleIntelligenceErrorView.swift` — AI非対応エラー画面
- `BakusokuMemoApp/Views/Input/InputView.swift` — 入力画面（バブル候補・送信・トースト・未分類バナー）
- `BakusokuMemoApp/Views/List/ThreadListView.swift` — スレッド一覧（検索・ロック・削除・一括削除）
- `BakusokuMemoApp/Views/List/ThreadRowView.swift` — スレッド行コンポーネント
- `BakusokuMemoApp/Views/Detail/ThreadDetailView.swift` — スレッド詳細（Markdownプレビュー・編集・AI指示）
- `BakusokuMemoApp/Views/Detail/MemoHistoryView.swift` — 元メモ履歴（デフォルト畳まれ）
- `BakusokuMemoApp/Views/Triage/TriageSheetView.swift` — 保留トリアージシート（ボトムシート）
- `BakusokuMemoApp/Views/Triage/TriageCardView.swift` — トリアージカード（スワイプジェスチャー）

### 変更なし（Phase 0で生成済み）

- `.github/` 以下の全エージェント・instructions・prompts・memoryファイル

---

## 3. タスク一覧

| #   | タスク                                                                                                                                                                     | 担当エージェント | 依存               | 完了条件                                                                 |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ------------------ | ------------------------------------------------------------------------ |
| 1   | Xcodeプロジェクト作成（iOS 26, Swift 6, SwiftUI, FoundationModels リンク）                                                                                                 | ios-architect    | なし               | `xcodebuild build` が通る                                                |
| 2   | ディレクトリ構成作成（App/, Models/, Views/, Features/, Generable/, Resources/）                                                                                           | ios-architect    | #1                 | 全フォルダが存在する                                                     |
| 3   | `BakusokuMemoApp.swift` 実装（`@main`・`ModelContainer`・`prewarm`・availability チェック）                                                                                | ios-engineer     | #2                 | ビルドが通る・シミュレーターで `AppleIntelligenceErrorView` が表示される |
| 4   | `Thread.swift` 実装（`@Model final class`・全プロパティ・`items` リレーション）                                                                                            | ios-engineer     | #2                 | Swift 6 strict concurrency で警告なし                                    |
| 5   | `ThreadItem.swift` 実装（`@Model final class`・`ItemType` enum）                                                                                                           | ios-engineer     | #2                 | Swift 6 strict concurrency で警告なし                                    |
| 6   | `PendingMemo.swift` 実装（`@Model final class`・全プロパティ）                                                                                                             | ios-engineer     | #2                 | Swift 6 strict concurrency で警告なし                                    |
| 7   | `ThreadSuggestion.swift` 実装（`@Generable struct`・`suggestions: [String]`）                                                                                              | ai-feature       | #3                 | `@Generable` マクロが展開されビルドが通る                                |
| 8   | `FormattedThread.swift` 実装（`@Generable struct`・`markdownContent`・`title`）                                                                                            | ai-feature       | #3                 | `@Generable` マクロが展開されビルドが通る                                |
| 9   | `actor ThreadFormatter` 実装（availability チェック・`LanguageModelSession` 使い捨て・バブル候補生成・スレッド統合・AI指示処理・`exceededContextWindowSize` ハンドリング） | ai-feature       | #4, #5, #6, #7, #8 | actor境界を越えて `@Model` インスタンスを渡さない・Swift 6 で警告なし    |
| 10  | `AppleIntelligenceErrorView.swift` 実装（エラーメッセージ・設定アプリ誘導・フォールバックUI一切なし）                                                                      | ui-designer      | #3                 | シミュレーターで `.unavailable` 時に表示される                           |
| 11  | `RootView.swift` 実装（`TabView` + `PageTabViewStyle`・index 0: InputView, index 1: ThreadListView）                                                                       | ui-designer      | #10                | 左右スワイプでページング遷移する                                         |
| 12  | `InputView.swift` 実装（`@FocusState` 自動フォーカス・バブル候補表示 debounce 2秒+10文字・送信フォームリセット・2段階トースト・「戻す」ボタン・未分類バナー）              | ui-designer      | #9, #11            | キーボード自動表示・バブル候補が2秒後に表示・送信後トーストが2段階で出る |
| 13  | `ThreadListView.swift` + `ThreadRowView.swift` 実装（検索バー・LINEトーク風リスト・長押し全文展開・🔒トグル・スピナー・左スワイプ削除・一括削除・未分類バナー）            | ui-designer      | #4, #9, #11        | 検索・削除・ロックトグルが機能する                                       |
| 14  | `ThreadDetailView.swift` 実装（Markdownプレビューモード・編集モード切替・タイトル編集・ロック表示・LLM処理中編集不可・AI指示バブルアイコン・入力欄展開・送信）             | ui-designer      | #9, #13            | プレビュー↔編集切替・AI指示送信後にMarkdownが更新される                  |
| 15  | `MemoHistoryView.swift` 実装（デフォルト畳まれ・タップ展開・ThreadItem 一覧表示・タイムスタンプ・AI指示ログ区別）                                                          | ui-designer      | #14                | 畳まれた状態で表示・タップで展開                                         |
| 16  | `TriageSheetView.swift` + `TriageCardView.swift` 実装（ボトムシート・1枚カード形式・AI候補3件+新規作成・右/上/左スワイプ・全消化で自動終了）                               | ui-designer      | #9, #6             | 3方向スワイプが機能・全カード消化でシートが閉じる                        |
| 17  | 入力→送信→AI整形→Thread統合 E2E フロー結合テスト                                                                                                                           | ios-engineer     | #12, #14           | 実機で送信後にスレッドのMarkdownが更新される                             |
| 18  | 保留メモ→トリアージ→登録 E2E フロー結合テスト                                                                                                                              | ios-engineer     | #16                | 実機でトリアージ完了後にスレッドへ統合される                             |
| 19  | iOS 26 シミュレーター動作確認（AI整形以外の全機能）                                                                                                                        | ios-engineer     | #17, #18           | シミュレーターで `AppleIntelligenceErrorView` 表示・ビルドエラーなし     |
| 20  | 実機（iPhone 15 Pro + Apple Intelligence 有効）AI整形テスト                                                                                                                | ios-engineer     | #17, #18           | バブル候補・スレッド統合・AI指示が期待通り動作する                       |
| 21  | Instruments App Launch 計測（起動時間 < 300ms）                                                                                                                            | ios-engineer     | #20                | 計測結果が 300ms 以内                                                    |
| 22  | コードレビュー（Swift 6 concurrency・`@Generable`・SwiftData 操作パターン）                                                                                                | reviewer         | #20                | 警告・エラーゼロ・ADR準拠が確認される                                    |

---

## 4. 実装順序

```
#1 → #2 → #3
            └→ #4, #5, #6（並行可）
            └→ #10 → #11
#3, #4, #5, #6 完了後 → #7, #8（並行可）
#7, #8 完了後 → #9
#9, #11 完了後 → #12, #13（並行可）
#13 完了後 → #14 → #15
#9, #6 完了後 → #16
#12, #14, #15, #16 完了後 → #17, #18（並行可）
#17, #18 完了後 → #19 → #20 → #21, #22（並行可）
```

**フェーズ別まとめ:**

| フェーズ              | タスク                          | 並行可能             |
| --------------------- | ------------------------------- | -------------------- |
| Phase 1: Xcode初期化  | #1 → #2 → #3                    | 直列                 |
| Phase 2: データモデル | #4, #5, #6                      | 並行可               |
| Phase 3: @Generable   | #7, #8                          | 並行可（#3完了後）   |
| Phase 4: AI整形機能   | #9                              | 直列（#4〜#8完了後） |
| Phase 5: Views        | #10→#11→#12/#13 → #14→#15 / #16 | 部分並行             |
| Phase 6: 統合・品質   | #17/#18 → #19 → #20 → #21/#22   | 部分並行             |

---

## 5. 注意事項

### Swift 6 / 並行処理（ISSUE-004）

- `actor ThreadFormatter` では `@Model` インスタンスを直接受け渡しせず、`UUID` 等プリミティブ値のみをactor境界越えで渡す
- SwiftData書き込みは `@MainActor` コンテキスト内のみで行う
- `@Observable` を ViewModel に使用（`ObservableObject` は不使用）

### Apple Intelligence / Foundation Models

- iOS 26 シミュレーターでは `availability` が `.unavailable(.deviceNotEligible)` になる（ISSUE-001）。AI整形テスト（#20）は実機必須
- `LanguageModelSession` はリクエストごとに生成・使い捨て（セッション再利用禁止）
- `Instructions` は session init 時に固定。動的変更不可
- `GenerationError.exceededContextWindowSize` は `catch` でUIエラー通知のみ。分割再試行は実装しない（ISSUE-002）

### SwiftData

- `@Model` は `final class` のみ（`struct` 不可）
- `ModelContainer` は `BakusokuMemoApp.swift`（`@main`）で1箇所のみ定義
- View は `@Environment(\.modelContext)` で context を取得

### @Generable（ISSUE-003）

- Deployment Target を iOS 26.0 に設定すること（プロジェクト作成時 #1 で対応）
- `@available` ガード不要（全ターゲットが iOS 26+）

---

## 6. 関連ADR

| ADR     | 内容                                             | 対応タスク          |
| ------- | ------------------------------------------------ | ------------------- |
| ADR-001 | UIフレームワーク — SwiftUI採用                   | #11〜#16            |
| ADR-002 | 永続化 — SwiftData採用                           | #3, #4, #5, #6      |
| ADR-003 | AI機能 — フォールバック実装しない                | #10, 全タスクで遵守 |
| ADR-004 | AIフレームワーク — Foundation Models採用         | #7, #8, #9          |
| ADR-005 | 並行処理 — `actor ThreadFormatter`               | #9                  |
| ADR-006 | データモデル — Thread / ThreadItem / PendingMemo | #4, #5, #6          |
| ADR-007 | ナビゲーション — 左右スワイプによるページング    | #11                 |
| ADR-008 | Markdown表示 — フル再生成方式                    | #9, #14             |
