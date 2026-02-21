# Architecture Decision Records (ADR)

> 設計判断を下したら ios-architect エージェントが追記する。削除・上書き禁止。

---

## ADR-001: UI フレームワーク — SwiftUI 採用

- **日付**: 2026-02-21
- **状況**: iOS アプリの UI フレームワーク選定
- **決定**: SwiftUI（iOS 26 API）を採用する
- **理由**: iOS 26 の最新 API との親和性が高い。Swift 6 strict concurrency とのネイティブ統合。`@Observable` / `@Query` / `#Preview` マクロなど宣言的UIが高速起動・シンプルな実装を実現
- **代替案**: UIKit（却下: ボイラープレートが多く、SwiftData との統合コストが高い）
- **結果**: View / ViewModel / SwiftData の統合がネイティブに行える

---

## ADR-002: 永続化 — SwiftData 採用

- **日付**: 2026-02-21
- **状況**: ローカル永続化ライブラリの選定
- **決定**: SwiftData（`@Model`, `@Query`, `ModelContainer`）を採用する
- **理由**: iOS 17+ かつ SwiftUI ネイティブ統合。`@Query` による自動 UI 更新。`@MainActor` との統合が明確。ボイラープレートが CoreData の 1/5 以下
- **代替案**: CoreData（却下: iOS 26 ターゲットで新規採用する理由がない）、UserDefaults（却下: 複雑なクエリ・リレーションに不向き）
- **結果**: メモの一覧・詳細・チェック状態を `@Query` で宣言的に管理できる

---

## ADR-003: AI 機能 — フォールバック実装しない

- **日付**: 2026-02-21
- **状況**: Apple Intelligence が利用できない環境でのアプリ動作方針
- **決定**: フォールバック実装（ルールベース整形・外部 API 呼び出しなど）は一切行わない
- **理由**: 本アプリは Apple Intelligence のコンセプト実証が目的。非対応デバイスはスコープ外。フォールバック実装はコードの複雑性を高め、コンセプトを希薄化する
- **代替案**: ルールベース整形（却下）、OpenAI API フォールバック（却下）
- **結果**: `SystemLanguageModel.default.availability` が `.unavailable` の場合はエラー画面（セットアップ誘導）を表示するのみ。コードがシンプルに保たれる

---

## ADR-004: AI フレームワーク — Foundation Models 採用

- **日付**: 2026-02-21
- **状況**: テキスト自動整形・分類に使う AI フレームワークの選定
- **決定**: Foundation Models フレームワーク（`SystemLanguageModel`, `LanguageModelSession`, `@Generable`）を採用する
- **理由**: オンデバイス推論でプライバシー保護。API キー不要・通信不要。`@Generable` による型安全な構造化出力。iOS 26 ネイティブ統合
- **代替案**: OpenAI API（却下: 通信必要・API キー管理コスト）、Core ML カスタムモデル（却下: モデル配布コスト・精度）
- **結果**: ネットワーク不要でオフライン完結。`FormattedMemo` 型で AI 出力を型安全に受け取れる

---

## ADR-005: 並行処理 — actor ThreadFormatter

- **日付**: 2026-02-21
- **状況**: Foundation Models の呼び出しと SwiftData への書き込みの並行処理設計
- **決定**: AI 整形処理を `actor ThreadFormatter` に隔離する。SwiftData 操作は `@MainActor` で分離する
- **理由**: Swift 6 strict concurrency を満たすために AI 処理（非 `@MainActor`）と UI/SwiftData 操作（`@MainActor`）を明確に分離する必要がある
- **代替案**: すべて `@MainActor` で処理（却下: AI 処理がメインスレッドをブロック）
- **結果**: AI 整形中も UI が応答可能。送信後にユーザーがアプリを閉じても処理が継続する

---

## ADR-006: データモデル — Thread / ThreadItem / PendingMemo

- **日付**: 2026-02-21
- **状況**: メモの永続化データモデル設計
- **決定**: `Thread`（スレッド）・`ThreadItem`（スレッド内アイテム/元メモログ）・`PendingMemo`（保留メモ）の3モデル構成を採用する
- **理由**: 「メモを投げる → AIがスレッドに統合」というUXに合わせ、Threadが中心エンティティとなる。元メモ履歴とAI指示ログはThreadItemとして蓄積。保留状態のメモはPendingMemoとして分離管理
- **代替案**: Memo / MemoItem（却下: スレッドが主役という設計に合わない）
- **結果**: `Thread.markdownContent` が真実のソース。`ThreadItem` が更新ログ。`PendingMemo` がトリアージ待ちキュー

---

## ADR-007: ナビゲーション — 左右スワイプによるページング

- **日付**: 2026-02-21
- **状況**: 入力画面 ↔ スレッド一覧の遷移方式
- **決定**: `TabView` + `PageTabViewStyle` による左右スワイプページングを採用する
- **理由**: 「起動直後に入力画面」「右スワイプで一覧」というUXを最小コードで実現できる。NavigationStackより遷移コストが低く、思考の流れを止めない
- **代替案**: NavigationStack（却下: push遷移のアニメーションが一覧↔入力の行き来に合わない）
- **結果**: 入力画面がindex 0、スレッド一覧がindex 1のPageView。スレッド詳細はスレッド一覧からNavigationStackでpush

---

## ADR-008: Markdown表示 — フル再生成方式

- **日付**: 2026-02-21
- **状況**: スレッドへのメモ追加時のMarkdown更新方式
- **決定**: 既存Markdown全文 + 新メモ をLLMに渡し、Markdown全文をレスポンスとして受け取るフル再生成方式を採用する
- **理由**: セクション差分更新はLLMへの指示が複雑になりプロンプトのメンテコストが高い。フル再生成のほうがシンプルで品質が安定する。生成時間はUX的に許容済み
- **代替案**: セクション差分更新（却下: 実装複雑・プロンプト不安定）
- **結果**: システムプロンプトに「変更最小化・セクション単位更新を推奨」と指示することで過剰な書き換えを抑制する
