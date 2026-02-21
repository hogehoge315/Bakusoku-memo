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

- [ ] `Memo.swift`（`@Model final class`）
- [ ] `MemoItem.swift`（`@Model final class`）
- [ ] SwiftData マイグレーションスキーマ設定

---

## Phase 3: @Generable 構造体

- [ ] `FormattedMemo.swift`（`@Generable`）
- [ ] `MemoType.swift`（`@Generable enum`）
- [ ] `MemoFormatterError.swift`（エラー定義）

---

## Phase 4: AI 整形機能（Features/）

- [ ] `actor MemoFormatter` 実装
  - [ ] `SystemLanguageModel.default.availability` チェック
  - [ ] `LanguageModelSession` 使い捨てパターン
  - [ ] `respond(to:generating:)` で `FormattedMemo` 取得
  - [ ] `GenerationError` ハンドリング
- [ ] アプリ起動時の `prewarm` 実装

---

## Phase 5: SwiftUI Views

- [ ] `RootView.swift`（ナビゲーションルート）
- [ ] `MemoListView.swift` + `MemoRowView.swift`
- [ ] `MemoInputView.swift`（自動フォーカス・フォーカスアウト確定）
- [ ] `MemoDetailView.swift`
  - [ ] `ChecklistView.swift`（shopping / todo 用）
  - [ ] `NoteView.swift`（note 用）
- [ ] `AppleIntelligenceErrorView.swift`（unavailable 時）

---

## Phase 6: 統合・品質

- [ ] フォーカスアウト → AI 整形 → SwiftData 保存 の E2E フロー結合
- [ ] iOS 26 シミュレーターでの動作確認（AI 整形以外）
- [ ] 実機（iPhone 15 Pro + Apple Intelligence 有効）での AI 整形テスト
- [ ] Instruments App Launch テンプレートで起動時間計測（目標: < 200ms）
- [ ] コードレビュー by reviewer エージェント
