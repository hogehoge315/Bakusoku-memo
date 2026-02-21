# Known Issues

> reviewer エージェントが問題発見時に追記する。削除禁止。解決時は `ステータス: Resolved` に変更する。

---

## [ISSUE-001] iOS 26 シミュレーターで Apple Intelligence が使えない

- **発見日**: 2026-02-21
- **対象ファイル**: `BakusokuMemoApp/Features/ThreadFormatter.swift`（実装予定）
- **深刻度**: Warning（開発フローの制約）
- **内容**: iOS 26 シミュレーターでは `SystemLanguageModel.default.availability` が `.unavailable(.deviceNotEligible)` を返す。AI 整形の動作確認がシミュレーターで行えない
- **対処方法**:
  1. シミュレーターでは `availability` チェックで `AppleIntelligenceErrorView` が表示されることを確認するテストを書く
  2. AI 整形の精度・動作確認は Apple Intelligence を有効にした iPhone 15 Pro 以降の実機で行う
- **ステータス**: Open（既知の環境制約・解決不可）

---

## [ISSUE-002] LanguageModelSession のコンテキストウィンドウ上限

- **発見日**: 2026-02-21
- **対象ファイル**: `BakusokuMemoApp/Features/ThreadFormatter.swift`（実装予定）
- **深刻度**: Warning
- **内容**: `LanguageModelSession` にはコンテキストウィンドウのサイズ制限がある。非常に長いテキストを入力した場合、`GenerationError.exceededContextWindowSize` が throw される
- **対処方法**: `catch GenerationError.exceededContextWindowSize` でユーザーに「テキストが長すぎます」を UI で通知する。テキストを分割して再試行する処理は書かない
- **ステータス**: Open

---

## [ISSUE-003] @Generable は iOS 26 以上でしか使えない

- **発見日**: 2026-02-21
- **対象ファイル**: `BakusokuMemoApp/Generable/` 以下全ファイル
- **深刻度**: Warning（デプロイターゲット管理）
- **内容**: `Foundation Models` フレームワーク・`@Generable` マクロは iOS 26 以上でのみ利用可能。Xcode プロジェクトの Deployment Target を iOS 26.0 以上に設定する必要がある
- **対処方法**: プロジェクト作成時に Deployment Target を iOS 26.0 に設定する。`@available` ガードは不要（全ターゲットが iOS 26+ のため）
- **ステータス**: Open

---

## [ISSUE-004] Swift 6 と SwiftData @Model の Sendable 警告

- **発見日**: 2026-02-21
- **対象ファイル**: `BakusokuMemoApp/Models/` 以下全ファイル
- **深刻度**: Warning
- **内容**: Swift 6 strict concurrency では `@Model` クラスを `actor` 境界を越えて渡す際に `Sendable` 準拠の警告が出る場合がある。SwiftData の `PersistentModel` プロトコルは `@unchecked Sendable` に準拠しているが、設計上 `ModelContext` は `@MainActor` 内でのみ操作する
- **対処方法**: `actor ThreadFormatter` では `@Model` インスタンスを直接保持・操作しない。`Thread.id`（`UUID`）などのプリミティブ値のみを `actor` 境界を越えて渡す
- **ステータス**: Open
