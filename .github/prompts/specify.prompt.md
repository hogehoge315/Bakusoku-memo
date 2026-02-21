````prompt
---
agent: Orchestrator
description: ユーザーの要件を受け取り、構造化された仕様書 (spec.md) を生成する
tools:
  - read/readFile
  - edit/createFile
  - search/codebase
model: Claude Sonnet 4.6 (copilot)
---

## タスク

ユーザーが入力した要件を元に、`docs/specs/{name}.spec.md` を生成してください。

---

### Step 1: コンテキスト確認

1. `memory/project-context.md` を読む
2. `memory/decisions.md` を読む（既存ADRとの整合性確認）
3. `memory/known-issues.md` を読む

### ✅ バリデーションゲート 1

- [ ] `memory/project-context.md` を読んだ
- [ ] 要件が「Apple Intelligence 必須・フォールバック不採用」方針（ADR-003）と矛盾しない
- [ ] `memory/known-issues.md` に要件をブロックする Critical Issue がない

---

### Step 2: 仕様書生成

`docs/specs/{name}.spec.md` を以下のテンプレートで作成する。
`{name}` はフィーチャー名をケバブケースで付ける（例: `thread-input`）。

```markdown
# {フィーチャー名} 仕様書

> 生成日: YYYY-MM-DD
> ステータス: Draft

---

## 1. 概要

[何を実現するか。1〜3文で]

---

## 2. UXフロー

[画面遷移・操作手順をステップ形式で]

---

## 3. 機能要件

### 3.1 必須
- [ ] [要件1]
- [ ] [要件2]

### 3.2 対象外（スコープ外）
- [明示的に除外する機能]

---

## 4. データ要件

| モデル | プロパティ | 型 | 説明 |
|--------|-----------|-----|------|
| Thread | title | String | ... |

---

## 5. AI 要件

- 入力: [LLMへの入力内容]
- 出力: [@Generable 型名と構造]
- システムプロンプト方針: [LLMへの指示の要点]

---

## 6. 受け入れ条件

- [ ] [テスト可能な条件1]
- [ ] [テスト可能な条件2]

---

## 7. 関連ADR

- ADR-XXX: [関連する設計決定]

---

## 8. 制約・注意事項

- [Swift 6 / Apple Intelligence に関する制約]
```

### ✅ バリデーションゲート 2: 仕様書チェック

- [ ] フォールバック実装・代替ロジックの要件が含まれていない
- [ ] 受け入れ条件がすべて「検証可能な形式」になっている
- [ ] AI 要件に `@Generable` 型が明示されている（raw `String` 出力ではない）
- [ ] スコープ外が明示されている

---

### Step 3: 出力確認

生成した `docs/specs/{name}.spec.md` のパスをユーザーに報告し、内容の確認を求める。
確定後 `plan.prompt.md` を使って計画フェーズに進む。

### 禁止事項

- フォールバック実装の仕様を書かない
- Apple Intelligence 非対応環境向けの代替フローを仕様に含めない
````
