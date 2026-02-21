# Memory システム

エージェント間でコンテキストを共有するためのメモリダンプ領域。
セッションをまたいでプロジェクトの状態・決定・進捗・問題を永続化する。

## ファイル一覧

| ファイル             | 内容                                       | 読むタイミング       | 書くタイミング       |
| -------------------- | ------------------------------------------ | -------------------- | -------------------- |
| `project-context.md` | アプリ要件・技術スタック・制約（不変情報） | 毎セッション開始時   | 要件変更時のみ       |
| `decisions.md`       | アーキテクチャ決定記録（ADR形式）          | 設計作業開始時       | 設計判断を下したとき |
| `progress.md`        | 実装進捗チェックリスト                     | 毎セッション開始時   | タスク完了のたびに   |
| `known-issues.md`    | 既知の問題・制約・回避策                   | 実装・レビュー開始時 | 問題発見時           |

## エージェント別 読み書きプロトコル

### orchestrator

- **読む**: `project-context.md`, `progress.md`, `decisions.md`
- **書く**: `progress.md`（タスク分解・完了時）

### ios-architect

- **読む**: `project-context.md`, `decisions.md`
- **書く**: `decisions.md`（ADR追記）

### ios-engineer

- **読む**: `project-context.md`, `progress.md`
- **書く**: `progress.md`（実装完了時）

### ai-feature

- **読む**: `project-context.md`, `decisions.md`
- **書く**: `decisions.md`（AI機能設計判断時）

### ui-designer

- **読む**: `project-context.md`
- **書く**: なし（設計判断は ios-architect 経由）

### reviewer

- **読む**: `project-context.md`, `known-issues.md`
- **書く**: `known-issues.md`（問題発見時）

## 更新ルール

1. 既存の内容を削除しない（追記のみ）
2. 日付を必ず記録する
3. 解決済みの issue は `ステータス: Resolved` に変更するが削除しない
