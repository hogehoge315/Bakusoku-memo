---
agent: iOS Engineer
description: SwiftData の @Model クラスを BakusokuMemoApp の規約に従って実装する
tools:
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - search/codebase
  - search/fileSearch
  - read/problems
model: Claude Sonnet 4.6 (copilot)
---

## タスク

以下の手順で SwiftData `@Model` クラスを実装してください。

### Step 1: 規約確認

1. `.github/instructions/swiftdata.instructions.md` を読む
2. `BakusokuMemoApp/Models/` 以下の既存モデルを確認してパターンを踏襲する

### ✅ バリデーションゲート 1: 実装事前確認

モデルの実装を始める前に以下をすべて確認すること。ひとつでも❌ならユーザーに報告する。

- [ ] `swiftdata.instructions.md` を読んだ
- [ ] `BakusokuMemoApp/App/BakusokuMemoApp.swift` が存在し、`.modelContainer(for:)` の追記先が確認できる
- [ ] 同名の `@Model` クラスが `BakusokuMemoApp/Models/` にすでに存在しない
- [ ] 既存モデルのプロパティを変更する場合、マイグレーションが必要か確認した

### Step 2: @Model クラス実装

`BakusokuMemoApp/Models/[名前].swift` を作成：

```swift
import Foundation
import SwiftData

@Model
final class [名前] {
    // MARK: - Properties
    var id: UUID
    var createdAt: Date
    // 追加プロパティ

    // MARK: - Relationships
    // @Relationship(deleteRule: .cascade) var items: [[子モデル]]

    // MARK: - Init
    init(...) {
        self.id = UUID()
        self.createdAt = Date()
        // 初期化
    }
}
```

**必須チェック**:

- `final class` のみ（`struct` は禁止）
- `@Relationship(deleteRule: .cascade)` を子エンティティに明示
- 列挙型プロパティは `String` / `Int` に変換して保存（SwiftData は生 enum を保存できない場合がある）
- `@Transient` で永続化不要なプロパティを明示（例: `isProcessing`）

### ✅ バリデーションゲート 2: @Model 定義チェック

ModelContainer への追加前に以下を確認すること。❌があれば修正する。

- [ ] `struct` ・ `class`（非 `final`）が使われていない
- [ ] enum プロパティが適切な型（`String`/`Int`）に変換されている
- [ ] `@Relationship` の `deleteRule` が子エンティティに明示されている
- [ ] `isProcessing` など永続化不要なプロパティに `@Transient` が付いている

### Step 3: ModelContainer に追加

`BakusokuMemoApp/App/BakusokuMemoApp.swift` の `.modelContainer(for:)` に新しいモデルを追加する：

```swift
.modelContainer(for: [Memo.self, MemoItem.self, [新モデル].self])
```

### Step 4: マイグレーション（スキーマ変更の場合）

既存モデルのプロパティを変更・追加する場合は `VersionedSchema` と `SchemaMigrationPlan` を定義する。

### Step 5: 問題チェック・progress 更新

`read/problems` でコンパイルエラーを確認し、`memory/progress.md` を更新する。

### ✅ バリデーションゲート 3: 完了確認

- [ ] `read/problems` に `@Model` 関連のコンパイルエラーがない
- [ ] `BakusokuMemoApp/App/BakusokuMemoApp.swift` の `.modelContainer(for:)` に新モデルが追加されている
- [ ] `ModelContainer` の定義が `BakusokuMemoApp.swift` の 1 箇所のみにある
- [ ] コンパイルエラーがない状態で `memory/progress.md` を更新した
