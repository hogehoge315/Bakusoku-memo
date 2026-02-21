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

- [x] Xcode プロジェクト作成（`BakusokuMemoApp`, iOS 26, Swift 6, SwiftUI）← xcodegen generate で生成
- [x] `FoundationModels` フレームワークリンク ← project.yml で設定済み
- [x] ディレクトリ構成作成（App/, Models/, Views/, Features/, Generable/, Resources/）
- [x] `BakusokuMemoApp.swift`（`@main`）+ `ModelContainer` 設定

---

## Phase 2: データモデル

- [x] `Thread.swift`（`@Model final class`）
  - `id`, `title`, `markdownContent`, `isLocked`, `isProcessing`, `updatedAt`
- [x] `ThreadItem.swift`（`@Model final class`）— 元メモ履歴・AI指示ログ
  - `id`, `threadId`, `rawText`, `itemType`（memo / aiInstruction）, `createdAt`
- [x] `PendingMemo.swift`（`@Model final class`）— 保留メモ
  - `id`, `rawText`, `createdAt`
- [ ] SwiftData マイグレーションスキーマ設定

---

## Phase 3: @Generable 構造体

- [x] `ThreadSuggestion.swift`（`@Generable`）— バブル候補・トリアージ候補
- [x] `FormattedThread.swift`（`@Generable`）— Markdown再生成レスポンス
- [x] `ThreadFormatterError.swift`（エラー定義）← `ThreadFormatter.swift` 内に定義

---

## Phase 4: AI 整形機能（Features/）

- [x] `actor ThreadFormatter` 実装
  - [x] `SystemLanguageModel.default.availability` チェック
  - [x] `LanguageModelSession` 使い捨てパターン
  - [x] バブル候補生成（入力テキスト → 既存スレッド候補3件）
  - [x] スレッド統合（既存Markdown全文 + 新メモ → Markdown再生成）
  - [x] AI指示処理（既存Markdown全文 + ユーザー指示 → Markdown再生成）
  - [x] `GenerationError.exceededContextWindowSize` ハンドリング
- [ ] アプリ起動時の `prewarm` 実装

---

## Phase 5: SwiftUI Views

- [x] `RootView.swift`（TabView + PageTabViewStyle で入力↔一覧）
- [x] `InputView.swift`（キーボードON・バブル候補・送信・未分類バナー）※ Phase 1 骨格
  - [ ] バブル候補コンポーネント（2秒 + 10文字 debounce）← 未実装
  - [ ] 送信後トースト（2段階 + 「戻す」ボタン）← 未実装
- [x] `ThreadListView.swift` + `ThreadRowView.swift`
  - [x] 検索バー
  - [x] 🔒ロックアイコン・スピナー
  - [x] 左スワイプ削除
  - [x] 未分類メモ N件バナー
  - [ ] 長押し全文展開 ← 未実装
  - [ ] 一括削除 ← 未実装
- [x] `ThreadDetailView.swift`
  - [x] Markdownプレビューモード / 編集モード切り替え（骨格）
  - [ ] AI指示バブルアイコン → 入力欄展開 ← 未実装
  - [x] `MemoHistoryView.swift`（元メモ履歴・デフォルト畳まれ）
- [x] `TriageSheetView.swift` + `TriageCardView.swift`
  - [x] 右/上/左スワイプアクション（登録/スキップ/廃棄）
- [x] `AppleIntelligenceErrorView.swift`（unavailable 時）

---

## Phase 6: 統合・品質

- [ ] 入力 → 送信 → AI整形 → Thread統合 の E2E フロー結合
- [ ] 保留メモ → トリアージ → 登録 の E2E フロー結合
- [ ] iOS 26 シミュレーターでの動作確認（AI 整形以外）
- [ ] 実機（iPhone 15 Pro + Apple Intelligence 有効）での AI 整形テスト
- [ ] Instruments App Launch テンプレートで起動時間計測（目標: < 300ms）
- [ ] コードレビュー by reviewer エージェント
