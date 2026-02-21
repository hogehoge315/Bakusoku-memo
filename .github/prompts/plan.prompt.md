---
agent: Orchestrator
description: spec.md を入力として受け取り、実装計画 plan.md を生成する
tools:
  - read/readFile
  - edit/createFile
  - search/codebase
  - search/fileSearch
model: Claude Sonnet 4.6 (copilot)
---

## 入力

`docs/specs/{name}.spec.md`（specify.prompt.md で生成済みのもの）

## 出力

`docs/plans/{name}.plan.md`

---

## タスク

spec.md を読み、実装タスクに分解した plan.md を生成してください。

### Step 1: コンテキスト収集

1. ユーザーが指定した `docs/specs/{name}.spec.md` を読む
2. `memory/project-context.md` を読む
3. `memory/decisions.md` を読む（既存ADRとの整合性確認）
4. `memory/progress.md` を読む（フェーズ・未完了タスクを確認）
5. `memory/known-issues.md` を読む

### ✅ バリデーションゲート 1

- [ ] spec.md のステータスが確定済みであることをユーザーが確認済み
- [ ] spec.md の要件が ADR-003（フォールバック不採用）と矛盾しない
- [ ] 同内容のタスクが `memory/progress.md` に未着手で存在しない
- [ ] Critical な known-issue がこのフィーチャーをブロックしていない

### Step 2: plan.md 生成

`docs/plans/{name}.plan.md` を以下のテンプレートで作成する。

```markdown
# {フィーチャー名} 実装計画

> 生成日: YYYY-MM-DD
> 入力Spec: docs/specs/{name}.spec.md
> ステータス: Draft

---

## 1. 概要

[spec の概要を1文で再掲]

---

## 2. 影響ファイル

### 新規作成

- `BakusokuMemoApp/Models/{Name}.swift` — [役割]
- `BakusokuMemoApp/Views/{Dir}/{Name}View.swift` — [役割]

### 変更

- `BakusokuMemoApp/App/BakusokuMemoApp.swift` — [変更内容]

---

## 3. タスク一覧

| #   | タスク     | 担当エージェント | 依存 | 完了条件                          |
| --- | ---------- | ---------------- | ---- | --------------------------------- |
| 1   | [タスク名] | ios-engineer     | なし | [ファイルが存在する等]            |
| 2   | [タスク名] | ui-designer      | #1   | [ビルドが通る等]                  |
| 3   | [タスク名] | ai-feature       | #1   | [@Generable 型が定義されている等] |

---

## 4. 実装順序

#1 → #2 → #3（直列）  
#2, #3 は並行可

---

## 5. 注意事項

- [Swift 6 / Apple Intelligence に関する制約]
- [既知の issues で注意が必要なもの]

---

## 6. 関連ADR

- ADR-XXX: [関連する設計決定]
```

### ✅ バリデーションゲート 2: plan.md チェック

- [ ] タスク一覧にフォールバック実装・代替ロジックのタスクが含まれていない
- [ ] 全タスクに担当エージェント名が明記されている
- [ ] 完了条件がすべて検証可能な形式
- [ ] 実装順序が依存関係と整合している
- [ ] 参照ADR番号が実在する

### Step 3: 完了報告

生成した `docs/plans/{name}.plan.md` のパスをユーザーに報告する。  
次は `implement.prompt.md` を使ってタスク #1 から実装を開始する。

### 禁止事項

- フォールバック実装のタスクを計画しない
- Apple Intelligence 非対応環境向けの代替フローを計画しない
- `memory/progress.md` を直接編集しない（update-context.prompt.md の役割）
