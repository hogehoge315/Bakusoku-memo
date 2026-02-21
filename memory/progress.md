# Progress

> ios-engineer・orchestrator エージェントが実装完了のたびに `[ ]` → `[x]` に更新する。
> 削除禁止。完了したものはチェックを入れるだけ。

---

## Phase 0: AI駆動開発インフラ

- [x] `.github/copilot-instructions.md` 作成
- [x] `.github/agents/orchestrator.agent.md` 作成
- [x] `.github/agents/ios-architect.agent.md` 作成
- [x] `.github/agents/ios-engineer.agent.md` 作成
- [x] `.github/agents/ai-feature.agent.md` 作成
- [x] `.github/agents/ui-designer.agent.md` 作成
- [x] `.github/agents/reviewer.agent.md` 作成
- [x] `.github/instructions/swiftui.instructions.md` 作成
- [x] `.github/instructions/swiftdata.instructions.md` 作成
- [x] `.github/instructions/foundation-models.instructions.md` 作成
- [x] `memory/` システム初期化
- [x] `.github/prompts/plan.prompt.md` 作成
- [x] `.github/prompts/implement-view.prompt.md` 作成
- [x] `.github/prompts/implement-model.prompt.md` 作成
- [x] `.github/prompts/implement-ai.prompt.md` 作成
- [x] `.github/prompts/review.prompt.md` 作成
- [x] `.github/prompts/progress.prompt.md` 作成
- [x] `.github/prompts/adr.prompt.md` 作成

---

## Phase 1: Xcode プロジェクト初期化

- [ ] Xcode プロジェクト作成（`BakusokuMemoApp`, iOS 26, Swift 6, SwiftUI）
- [ ] `FoundationModels` フレームワークリンク
- [ ] ディレクトリ構成作成（App/, Models/, Views/, Features/, Generable/, Resources/）
- [ ] `BakusokuMemoApp.swift`（`@main`）+ `ModelContainer` 設定

---

## Phase 2: データモデル

- [ ] `Thread.swift`（`@Model final class`）
  - `id`, `title`, `markdownContent`, `isLocked`, `isProcessing`, `updatedAt`
- [ ] `ThreadItem.swift`（`@Model final class`）— 元メモ履歴・AI指示ログ
  - `id`, `threadId`, `rawText`, `itemType`（memo / aiInstruction）, `createdAt`
- [ ] `PendingMemo.swift`（`@Model final class`）— 保留メモ
  - `id`, `rawText`, `createdAt`
- [ ] SwiftData マイグレーションスキーマ設定

---

## Phase 3: @Generable 構造体

- [ ] `ThreadSuggestion.swift`（`@Generable`）— バブル候補・トリアージ候補
- [ ] `FormattedThread.swift`（`@Generable`）— Markdown再生成レスポンス
- [ ] `ThreadFormatterError.swift`（エラー定義）

---

## Phase 4: AI 整形機能（Features/）

- [ ] `actor ThreadFormatter` 実装
  - [ ] `SystemLanguageModel.default.availability` チェック
  - [ ] `LanguageModelSession` 使い捨てパターン
  - [ ] バブル候補生成（入力テキスト → 既存スレッド候補3件）
  - [ ] スレッド統合（既存Markdown全文 + 新メモ → Markdown再生成）
  - [ ] AI指示処理（既存Markdown全文 + ユーザー指示 → Markdown再生成）
  - [ ] `GenerationError.exceededContextWindowSize` ハンドリング
- [ ] アプリ起動時の `prewarm` 実装

---

## Phase 5: SwiftUI Views

- [ ] `RootView.swift`（TabView + PageTabViewStyle で入力↔一覧）
- [ ] `InputView.swift`（キーボードON・バブル候補・送信・未分類バナー）
  - [ ] バブル候補コンポーネント（2秒 + 10文字 debounce）
  - [ ] 送信後トースト（2段階 + 「戻す」ボタン）
- [ ] `ThreadListView.swift` + `ThreadRowView.swift`
  - [ ] 検索バー
  - [ ] 🔒ロックアイコン・スピナー・長押し展開
  - [ ] 左スワイプ削除・一括削除
  - [ ] 未分類メモ N件バナー
- [ ] `ThreadDetailView.swift`
  - [ ] Markdownプレビューモード / 編集モード切り替え
  - [ ] AI指示バブルアイコン → 入力欄展開
  - [ ] `MemoHistoryView.swift`（元メモ履歴・デフォルト畳まれ）
- [ ] `TriageSheetView.swift` + `TriageCardView.swift`
  - [ ] 右/上/左スワイプアクション（登録/スキップ/廃棄）
- [ ] `AppleIntelligenceErrorView.swift`（unavailable 時）

---

## Phase 6: 統合・品質

- [ ] 入力 → 送信 → AI整形 → Thread統合 の E2E フロー結合
- [ ] 保留メモ → トリアージ → 登録 の E2E フロー結合
- [ ] iOS 26 シミュレーターでの動作確認（AI 整形以外）
- [ ] 実機（iPhone 15 Pro + Apple Intelligence 有効）での AI 整形テスト
- [ ] Instruments App Launch テンプレートで起動時間計測（目標: < 300ms）
- [ ] コードレビュー by reviewer エージェント
