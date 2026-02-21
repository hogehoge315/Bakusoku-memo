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
final class Thread {
    var id: UUID
    var title: String
    var markdownContent: String
    var isLocked: Bool
    @Transient var isProcessing: Bool = false
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var items: [ThreadItem]

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.markdownContent = ""
        self.isLocked = false
        self.updatedAt = Date()
        self.items = []
    }
}

@Model
final class ThreadItem {
    var id: UUID
    var rawText: String
    var itemType: String  // "memo" or "aiInstruction"
    var createdAt: Date

    init(rawText: String, itemType: String) {
        self.id = UUID()
        self.rawText = rawText
        self.itemType = itemType
        self.createdAt = Date()
    }
}

@Model
final class PendingMemo {
    var id: UUID
    var rawText: String
    var createdAt: Date

    init(rawText: String) {
        self.id = UUID()
        self.rawText = rawText
        self.createdAt = Date()
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
        .modelContainer(for: [Thread.self, ThreadItem.self, PendingMemo.self])
    }
}
```

### @MainActor 制約

- SwiftData の `ModelContext` への操作は必ず `@MainActor` コンテキストで行う
- `actor` 内から直接 `context.insert()` / `context.delete()` を呼ばない

```swift
// OK
@MainActor
func saveThread(_ thread: Thread, context: ModelContext) {
    context.insert(thread)
}

// NG — actor 内から MainActor コンテキストなしで呼ぶ
actor SomeActor {
    func save(context: ModelContext) {
        context.insert(Thread(title: "")) // ⚠️
    }
}
```

### @Query の正しい使い方

```swift
// OK: View 内で @Query
@Query(sort: \Thread.updatedAt, order: .reverse)
private var threads: [Thread]

// NG: @Query をメソッドの引数に渡す
func display(memos: [Memo]) { ... } // 直接 @Query 結果を受ける View を設計する
```

### 禁止事項

- `@Model` に `struct` を使わない
- `ModelContext` を `actor` 内に保持しない（thread-unsafe）
- `try? modelContext.save()` を忘れない（必要に応じて明示的に保存）
