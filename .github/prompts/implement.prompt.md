````prompt
---
agent: ios-engineer / ui-designer / ai-feature
description: plan.md のタスクを受け取り、Swift コードとテストを実装する
tools:
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - search/codebase
  - search/fileSearch
  - read/problems
model: Claude Sonnet 4.6 (copilot)
---

## 入力

`docs/plans/{name}.plan.md`（plan.prompt.md で生成済みのもの）

## 出力

- `BakusokuMemoApp/**/*.swift`（実装コード）
- `BakusokuMemoAppTests/**/*.swift`（テストコード）

---

## タスク

plan.md の指定タスクを実装してください。

---

### Step 1: 規約・コンテキスト確認

1. `docs/plans/{name}.plan.md` を読む（実装対象タスクを確認）
2. `memory/project-context.md` を読む（ディレクトリ構成・絶対制約を確認）
3. タスク種別に応じた instructions を読む：
   - **SwiftData @Model** → `.github/instructions/swiftdata.instructions.md`
   - **SwiftUI View** → `.github/instructions/swiftui.instructions.md`
   - **Foundation Models** → `.github/instructions/foundation-models.instructions.md`

### ✅ バリデーションゲート 1: 実装前確認

- [ ] plan.md の対象タスクを確認した
- [ ] 該当 instructions ファイルを読んだ
- [ ] 実装対象ファイルが既に存在しない（上書きしない）
- [ ] 依存タスクが完了済みであることを確認した（または並行可と plan に記載あり）

---

### Step 2: 実装

タスク種別別のルールに従って実装する。

---

#### 🗄 SwiftData @Model（担当: ios-engineer）

`BakusokuMemoApp/Models/{Name}.swift` を作成：

```swift
import Foundation
import SwiftData

@Model
final class {Name} {
    // MARK: - Properties
    var id: UUID
    var createdAt: Date

    // MARK: - Relationships
    // @Relationship(deleteRule: .cascade) var items: [{子モデル}] = []

    // MARK: - Init
    init(...) {
        self.id = UUID()
        self.createdAt = Date()
    }
}
````

**必須ルール**:

- `final class` のみ（`struct` 禁止）
- 子エンティティは `@Relationship(deleteRule: .cascade)` を明示
- enum プロパティは `String`/`Int` に変換して保存
- 永続化不要プロパティは `@Transient` を付ける
- 実装後、`BakusokuMemoApp.swift` の `.modelContainer(for:)` に追加する

---

#### 🖼 SwiftUI View（担当: ui-designer）

`BakusokuMemoApp/Views/{Dir}/{Name}View.swift` を作成：

```swift
import SwiftUI
import SwiftData

struct {Name}View: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = {Name}ViewModel()

    var body: some View {
        // 実装
    }
}

#Preview {
    {Name}View()
        .modelContainer(for: [...], inMemory: true)
}
```

ViewModel は `@Observable` で作成（`ObservableObject` 禁止）：

```swift
@Observable
final class {Name}ViewModel {
    var isProcessing = false

    @MainActor
    func someAction(context: ModelContext) async {
        // 実装
    }
}
```

**必須ルール**:

- `@Observable` を使う（`ObservableObject` / `@StateObject` 禁止）
- `ModelContext` を `init` で受け取らない（View から `@Environment` で渡す）
- `DispatchQueue.main.async` 禁止（`@MainActor` で代替）
- `NavigationView` 禁止（`NavigationStack` を使う）
- AI 処理中は `isProcessing` + `ProgressView` / ボタン非活性でハンドリング

---

#### 🤖 Foundation Models（担当: ai-feature）

`BakusokuMemoApp/Generable/{Name}.swift` を作成：

```swift
import FoundationModels

@Generable
struct {Name} {
    @Guide(description: "プロパティの意図を日本語で明示")
    var property: Type
}
```

`BakusokuMemoApp/Features/{Name}.swift` を作成：

```swift
import FoundationModels

actor {Name} {
    func process(_ input: String) async throws -> {Generable型} {
        // 1. availability チェック（必須・先頭）
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(let reason):
            throw {Error}.appleIntelligenceUnavailable(reason)
        }

        // 2. セッションを毎回新規生成（使い捨て）
        let session = LanguageModelSession(
            instructions: Instructions("システムプロンプト")
        )

        // 3. 構造化出力で受け取る
        let response = try await session.respond(
            to: Prompt(input),
            generating: {Generable型}.self
        )
        return response.content
    }
}
```

**必須ルール**:

- 全 `@Generable` プロパティに `@Guide(description:)` を付与
- `LanguageModelSession` をプロパティに保持しない（毎回 `init`）
- `.unavailable` 時はエラーを throw するのみ（フォールバック処理禁止）
- `@Model` インスタンスを actor 境界を越えて渡さない（`UUID` 等プリミティブのみ渡す）
- `exceededContextWindowSize` を catch してユーザーへ通知する

---

### ✅ バリデーションゲート 2: 実装後チェック

#### 共通

- [ ] ビルドエラーがない（`read/problems` で確認）
- [ ] フォールバック実装・代替ロジックが混入していない
- [ ] Swift 6 concurrency 違反がない

#### @Model

- [ ] `final class` になっている
- [ ] `@Transient` が必要なプロパティに付いている
- [ ] `ModelContainer` への追加が完了している

#### View

- [ ] `@Observable` が使われている（`ObservableObject` / `@StateObject` がない）
- [ ] `#Preview` が実装されている
- [ ] LLM 処理中のロック UI が実装されている

#### Foundation Models

- [ ] 全 `@Generable` プロパティに `@Guide` が付いている
- [ ] `availability` チェックが関数の先頭にある
- [ ] `LanguageModelSession` をプロパティに保持していない

---

### Step 3: テスト実装

`BakusokuMemoAppTests/{Name}Tests.swift` を作成。

- `@Model` のテスト: `inMemory: true` の `ModelContainer` を使う
- AI 機能のテスト: `availability` が `.unavailable` の場合にエラーが throw されることを確認
- View のテスト: `#Preview` のスナップショット or XCUITest

---

### Step 4: 完了報告

実装したファイル一覧をユーザーに報告する。  
次は `update-context.prompt.md` で memory を更新する。

```

```
