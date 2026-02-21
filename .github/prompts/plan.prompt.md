---
agent: Orchestrator
description: 実装するフィーチャーを計画し、タスクを分解して memory/progress.md に記録する
tools:
  - read/readFile
  - edit/editFiles
  - search/codebase
  - search/fileSearch
model: Claude Sonnet 4.6 (copilot)
---

## タスク

以下の手順でフィーチャーの実装計画を作成してください。

### Step 1: コンテキスト収集

1. `memory/project-context.md` を読む
2. `memory/decisions.md` を読む（既存ADRとの整合性確認）
3. `memory/progress.md` を読む（現在のフェーズ・未完了タスクを確認）
4. `memory/known-issues.md` を読む（影響する既知問題がないか確認）

### ✅ バリデーションゲート 1: コンテキスト確認

次のステップに進む前に以下をすべて確認すること。ひとつでも❌ならユーザーに報告して中止する。

- [ ] `memory/project-context.md` を読んだ
- [ ] 計画するフィーチャーが「Apple Intelligence 必須」の方針（ADR-003）と矛盾しない
- [ ] 同じフィーチャーが `memory/progress.md` に未着手タスクとしてすでに存在しない
- [ ] `memory/known-issues.md` にこのフィーチャーをブロックする未解決 Critical Issue がない

### Step 2: 計画立案

ユーザーが指定したフィーチャーについて以下を作成してください：

```
## フィーチャー: [フィーチャー名]

### 概要
[1〜2文で何を実装するか]

### 影響ファイル
- 新規作成: BakusokuMemoApp/[パス]
- 変更: BakusokuMemoApp/[パス]

### タスク分解
1. [ ] [タスク1] → 担当: [エージェント名]
2. [ ] [タスク2] → 担当: [エージェント名]
...

### 完了条件
- [ ] [検証可能な完了条件1]
- [ ] [検証可能な完了条件2]

### 関連ADR
- ADR-XXX: [関連する既存の設計決定]

### 注意事項
- [Apple Intelligence・Swift 6 に関する制約や注意点]
```

### ✅ バリデーションゲート 2: 計画内容チェック

`memory/progress.md` への追記前に以下を確認すること。ひとつでも❌ならユーザーに確認を求める。

- [ ] タスク一覧にフォールバック実装・代替ロジックのタスクが含まれていない
- [ ] 完了条件がすべて「ファイルが存在する」「ビルドが通る」などの検証可能な形式になっている
- [ ] 各タスクに担当エージェント名が明記されている
- [ ] 関連ADRが正しく参照されている（存在しないADR番号を参照していない）

### Step 3: memory/progress.md に追記

計画したタスクを `memory/progress.md` の適切なフェーズに `[ ]` 形式で追記する。
既存の項目は削除・変更しない。

### ✅ バリデーションゲート 3: 追記後の整合性確認

- [ ] `memory/progress.md` の既存チェック済み項目（`[x]`）が変更・削除されていない
- [ ] 新規追加タスクが既存タスクと重複していない
- [ ] フェーズの順序が論理的に正しい（依存関係が崩れていない）

### 禁止事項

- フォールバック実装のタスクを計画しない
- Apple Intelligence 非対応環境向けの代替フローを計画しない
