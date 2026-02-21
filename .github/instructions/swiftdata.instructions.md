---
applyTo: "**/Models/**/*.swift"
---

## SwiftData 実装規約

### @Model クラス定義

- `@Model` は `final class` のみ（`struct` は不可）
- `Codable` に準拠する必要はないが、プロパティは SwiftData がサポートする型のみ使う
- `@Relationship(deleteRule: .cascade)` を子エンティティに必ず明示する

```swift
@Model
final class Memo {
    var id: UUID
    var rawInput: String
    var title: String
    var memoType: String      // enum は String に変換して保存
    var items: [MemoItem]
    var isProcessing: Bool
    var createdAt: Date

    init(rawInput: String) {
        self.id = UUID()
        self.rawInput = rawInput
        self.title = ""
        self.memoType = "note"
        self.items = []
        self.isProcessing = true
        self.createdAt = Date()
    }
}

@Model
final class MemoItem {
    var text: String
    var isChecked: Bool
    var sortOrder: Int

    init(text: String, sortOrder: Int) {
        self.text = text
        self.isChecked = false
        self.sortOrder = sortOrder
    }
}
```

### ModelContainer

- `@main` の `App` 構造体で **1 箇所のみ** `.modelContainer(for:)` を呼ぶ
- 複数のモデルを配列で渡す

```swift
@main
struct BakusokuMemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Memo.self, MemoItem.self])
    }
}
```

### @MainActor 制約

- SwiftData の `ModelContext` への操作は必ず `@MainActor` コンテキストで行う
- `actor` 内から直接 `context.insert()` / `context.delete()` を呼ばない

```swift
// OK
@MainActor
func saveMemo(_ memo: Memo, context: ModelContext) {
    context.insert(memo)
}

// NG — actor 内から MainActor コンテキストなしで呼ぶ
actor SomeActor {
    func save(context: ModelContext) {
        context.insert(Memo(rawInput: "")) // ⚠️
    }
}
```

### @Query の正しい使い方

```swift
// OK: View 内で @Query
@Query(sort: \Memo.createdAt, order: .reverse)
private var memos: [Memo]

// NG: @Query をメソッドの引数に渡す
func display(memos: [Memo]) { ... } // 直接 @Query 結果を受ける View を設計する
```

### 禁止事項

- `@Model` に `struct` を使わない
- `ModelContext` を `actor` 内に保持しない（thread-unsafe）
- `try? modelContext.save()` を忘れない（必要に応じて明示的に保存）
