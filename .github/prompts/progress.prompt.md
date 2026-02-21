---
agent: Orchestrator
description: 実装済みファイルを確認して memory/progress.md のチェックリストを最新状態に同期する
tools:
  - read/readFile
  - edit/editFiles
  - search/fileSearch
  - search/codebase
model: Claude Sonnet 4.6 (copilot)
---

## タスク

実装済みファイルの存在を確認し、`memory/progress.md` のチェックリストを現状に合わせて更新してください。

### Step 1: 現在の progress を読む

`memory/progress.md` を読んで、`[ ]`（未完了）のタスクを一覧する。

### Step 2: ファイル存在確認

各タスクに対応するファイルが実際に存在するか `search/fileSearch` で確認する。

確認対象の主なパス：

```
BakusokuMemoApp/App/BakusokuMemoApp.swift
BakusokuMemoApp/Models/Memo.swift
BakusokuMemoApp/Models/MemoItem.swift
BakusokuMemoApp/Generable/FormattedMemo.swift
BakusokuMemoApp/Generable/MemoType.swift
BakusokuMemoApp/Features/MemoFormatter.swift
BakusokuMemoApp/Views/List/MemoListView.swift
BakusokuMemoApp/Views/Input/MemoInputView.swift
BakusokuMemoApp/Views/Detail/MemoDetailView.swift
BakusokuMemoApp/Views/Error/AppleIntelligenceErrorView.swift
```

### ✅ バリデーションゲート 1: ファイルスキャン完了確認

`memory/progress.md` を更新する前に以下を確認すること。ひとつでも❌なら再度スキャンする。

- [ ] `memory/progress.md` の全みの `[ ]` タスクに対してファイル存在を確認した
- [ ] 存在・未存在の結果一覧を得た
- [ ] 即座チェックできないタスク（「設定済みか」「ビルドが通るか」等）についてユーザーに確認した

### Step 3: 存在確認の結果をレポート

```
## 進捗確認結果

| タスク | ファイル | 状態 |
|--------|----------|------|
| Memo.swift | BakusokuMemoApp/Models/Memo.swift | ✅ 存在 / ❌ 未作成 |
...
```

### Step 4: memory/progress.md を更新

ファイルが存在するタスクの `[ ]` を `[x]` に更新する。

**ルール**:

- `[x]` を `[ ]` に戻さない（退行禁止）
- 追加タスクはユーザーに確認してから追記する
- 既存の項目の文言を変更しない

### ✅ バリデーションゲート 2: 更新内容の正しさ確認

`memory/progress.md` の更新実行後、次のアクションを提案する前に以下を確認する。ひとつでも❌なら差分をユーザーに報告する。

- [ ] ファイルが存在するタスクのみ `[x]` に変更した（存在しないのに `[x]` にしていない）
- [ ] 既存の `[x]` 項目が `[ ]` に戻っていない（退行なし）
- [ ] 既存項目の文言が変更されていない

### Step 5: 次のアクションを提案

未完了タスクの中から次に着手すべき項目を `memory/decisions.md` のADRを参照しながら優先順で提案する。
