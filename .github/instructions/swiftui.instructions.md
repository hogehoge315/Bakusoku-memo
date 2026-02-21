---
applyTo: "**/Views/**/*.swift"
---

## SwiftUI 実装規約

### ViewModel

- `@Observable` を使う（`ObservableObject` は絶対に使わない）
- `@StateObject` / `@EnvironmentObject` は禁止
- ViewModel は `final class` で定義する

```swift
// OK
@Observable
final class MemoInputViewModel {
    var rawText: String = ""
    var isProcessing: Bool = false
}

// NG
class MemoInputViewModel: ObservableObject {
    @Published var rawText: String = ""
}
```

### SwiftData との連携

- `@Environment(\.modelContext)` で context を取得する
- `@Query` は View 内でのみ使い、引数として渡さない

```swift
struct ThreadListView: View {
    @Query(sort: \Thread.updatedAt, order: .reverse)
    private var threads: [Thread]

    @Environment(\.modelContext) private var context
}
```

### AI 処理中の UI ハンドリング

- `.task` modifier を使い、`ProgressView` で処理中を表示する
- 処理はノンブロッキングにし、完了後に UI が自動更新されるように設計する

```swift
.task {
    await viewModel.processWithAI()
}
```

### ナビゲーション

- `NavigationStack` を使う（`NavigationView` は禁止）
- iOS 26 の新 API（`#Preview` マクロ等）を積極利用する

### 自動フォーカス

- 入力画面は `onAppear` で `@FocusState` を `true` にしてキーボードを自動表示する

```swift
.onAppear { isFocused = true }
```

### 禁止事項

- `AppDelegate` を作らない
- `UIViewController` を直接使わない
- `DispatchQueue.main.async` を使わない（`@MainActor` / `Task { @MainActor in }` を使う）
