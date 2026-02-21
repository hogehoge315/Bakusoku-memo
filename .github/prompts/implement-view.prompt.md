---
agent: UI Designer
description: SwiftUI View と @Observable ViewModel を BakusokuMemoApp の規約に従って実装する
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

以下の手順で SwiftUI View と ViewModel を実装してください。

### Step 1: 規約確認

1. `.github/instructions/swiftui.instructions.md` を読む
2. `memory/project-context.md` のディレクトリ構成を確認する
3. 既存の View ファイルがあれば `BakusokuMemoApp/Views/` 以下を確認してパターンを踏襲する

### ✅ バリデーションゲート 1: 実装事前確認

実装を始める前に以下をすべて確認すること。ひとつでも❌なら実装を中止しユーザーに報告する。

- [ ] `swiftui.instructions.md` を読んだ
- [ ] 実装対象の View 名・フォルダーが `BakusokuMemoApp/Views/[List|Input|Detail|Error]/` のいずれかに属する
- [ ] AI 処理を融合する場合、`actor MemoFormatter` がすでに実装済みか・未実装なら未実装であることをユーザーが承知している
- [ ] 同名の View ファイルがすでに存在しない

### Step 2: ViewModel 実装

`BakusokuMemoApp/Views/[サブフォルダ]/[名前]ViewModel.swift` を作成：

```swift
import Foundation
import SwiftData

@Observable
final class [名前]ViewModel {
    // State properties

    // Dependencies（ModelContext は View から @Environment で渡す）

    // Actions
    @MainActor
    func [action]() async {
        // 実装
    }
}
```

**必須チェック**:

- `@Observable` を使う（`ObservableObject` は禁止）
- `ModelContext` をイニシャライザで受け取らない（View から `@Environment` で渡す）
- AI 処理を呼ぶ場合は `isProcessing: Bool` プロパティを持つ

### ✅ バリデーションゲート 2: ViewModel チェック

View の実装に進む前に以下を確認する。❌があれば修正してから次のステップへ進む。

- [ ] `ObservableObject` ・ `@StateObject` ・ `@EnvironmentObject` が使われていない
- [ ] `ModelContext` を `init` の引数で受け取っていない
- [ ] `DispatchQueue.main.async` が使われていない（`@MainActor` で代替）

### Step 3: View 実装

`BakusokuMemoApp/Views/[サブフォルダ]/[名前]View.swift` を作成：

```swift
import SwiftUI
import SwiftData

struct [名前]View: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = [名前]ViewModel()

    var body: some View {
        // iOS 26 API を積極利用
    }
}

#Preview {
    [名前]View()
        .modelContainer(for: [Model].self, inMemory: true)
}
```

**必須チェック**:

- `@Environment(\.modelContext)` で context を取得
- `@Query` を View 内で直接使う
- AI 処理中は `.task` + `ProgressView` でハンドリング
- `NavigationStack` を使う（`NavigationView` 禁止）
- `@FocusState` 入力画面は `onAppear` で自動フォーカス
- `#Preview` マクロを使う

### Step 4: 問題チェック

実装後に `read/problems` でコンパイルエラー・警告を確認し、Swift 6 concurrency 違反を修正する。

### ✅ バリデーションゲート 3: 実装完了確認

`memory/progress.md` を更新する前に以下をすべて確認する。かひとつでも ❌ なら修正してから更新する。

- [ ] `read/problems` にコンパイルエラーがない（警告は許容，エラーは不可）
- [ ] Swift 6 concurrency 違反がない（`Sendable` ・ `@MainActor` 違反）
- [ ] `NavigationView` ・ `ObservableObject` ・ `DispatchQueue.main` が使われていない
- [ ] `#Preview` が実装されている

### Step 5: memory/progress.md 更新

対応するタスクの `[ ]` を `[x]` に更新する。
