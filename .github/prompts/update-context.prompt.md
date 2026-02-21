```prompt
---
agent: iOS Architect
description: 実装・レビュー完了後に memory/ の各ファイルを最新状態に同期する
tools:
  - read/readFile
  - edit/editFiles
  - search/fileSearch
  - search/codebase
  - search/changes
model: Claude Sonnet 4.6 (copilot)
---

## 入力

- 実装済みコード (`BakusokuMemoApp/**/*.swift`)
- レビューレポート (`docs/reviews/{name}.review.md`)（存在する場合）

## 出力

更新済みの `memory/` ファイル群

---

## タスク

実装・レビューの完了を受け、memory/ ファイルを一括更新してください。

---

### Step 1: 現在の状態確認

1. `memory/project-context.md` を読む
2. `memory/decisions.md` を読む（最後のADR番号を確認）
3. `memory/progress.md` を読む（未完了タスクを確認）
4. `memory/known-issues.md` を読む（最後のISSUE番号を確認）
5. `search/changes` で今回の変更ファイルを確認する

### ✅ バリデーションゲート 1

- [ ] 4つの memory ファイルを読んだ
- [ ] 変更ファイルの一覧を把握した
- [ ] 今回の変更にアーキテクチャ上の新しい判断が含まれているか確認した

---

### Step 2: memory/progress.md の更新

実装済みファイルの存在を `search/fileSearch` で確認し、対応タスクを `[ ]` → `[x]` に更新する。

**ルール**:
- 既存の `[x]` 済み項目は変更・削除しない
- ファイルが存在することを確認してから `[x]` にする
- 存在確認できないタスク（設定済みか・ビルドが通るか等）はユーザーに確認する

確認テーブルを作成してから更新する：

```

| タスク       | ファイル                            | 状態    |
| ------------ | ----------------------------------- | ------- |
| Thread.swift | BakusokuMemoApp/Models/Thread.swift | ✅ 存在 |

````

---

### Step 3: memory/decisions.md への ADR 追記

今回の実装で**新しいアーキテクチャ上の判断**があった場合のみ ADR を追記する。

判断の例：
- 新しいフレームワーク・ライブラリを採用した
- データモデルの設計方針を変更した
- 並行処理の設計を変更した
- UIパターンを新たに決定した

テンプレート：

```markdown
---

## ADR-{次番号}: {タイトル（動詞+名詞で簡潔に）}

- **日付**: YYYY-MM-DD
- **状況**: [なぜこの決定が必要になったか]
- **決定**: [何を決めたか。1〜2文で]
- **理由**: [技術的・UX的・制約的な根拠]
- **代替案**: [検討したが採用しなかった選択肢と却下理由]
- **結果**: [この決定による影響・トレードオフ]
````

**ルール**:

- 既存の ADR は削除・変更しない（追記のみ）
- ADR-003（フォールバック不採用）と矛盾する ADR を書かない

---

### Step 4: memory/known-issues.md への追記

レビューレポート (`docs/reviews/{name}.review.md`) の 🔴 Critical 問題があれば追記する。

```markdown
## [ISSUE-{次番号}] {タイトル}

- **発見日**: YYYY-MM-DD
- **対象ファイル**: `BakusokuMemoApp/...`
- **深刻度**: Critical / Warning
- **内容**: [問題の詳細]
- **対処方法**: [修正方法]
- **ステータス**: Open
```

**ルール**:

- 既存の ISSUE は削除・変更しない
- 解決済みの ISSUE はステータスを `Resolved` に変更するだけ

---

### Step 5: memory/project-context.md の更新（必要な場合のみ）

以下のいずれかに該当する場合のみ更新する：

- コアユースケースが変更された
- ディレクトリ構成が変更された
- 技術スタックが変更された
- 絶対制約が変更された

単なる機能追加では更新しない。

---

### ✅ バリデーションゲート 2: 更新後の整合性確認

- [ ] `memory/progress.md` の既存 `[x]` 項目が変更・削除されていない
- [ ] 新規追加のチェック済み `[x]` はすべてファイル存在確認済み
- [ ] ADR 番号が連番で正しい（最大番号 + 1）
- [ ] ISSUE 番号が連番で正しい（最大番号 + 1）
- [ ] 追記した ADR が ADR-003 と矛盾していない

---

### Step 6: 完了報告

更新した内容をユーザーに報告する：

```
## memory 更新完了

### progress.md
- [x] にしたタスク: N件
  - [タスク名] (ファイル確認済み)

### decisions.md
- 追記した ADR: ADR-XXX「タイトル」（or なし）

### known-issues.md
- 追記した ISSUE: ISSUE-XXX（or なし）

### project-context.md
- 更新: あり/なし（更新した場合は内容の要約）
```

```

```
