---
agent: AI Feature
description: Foundation Models の @Generable 構造体と actor を使った AI 整形機能を実装する
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

以下の手順で Foundation Models を使った AI 整形機能を実装してください。

### Step 1: 規約・コンテキスト確認

1. `.github/instructions/foundation-models.instructions.md` を読む
2. `memory/decisions.md` の ADR-003（フォールバック不採用）・ADR-004（Foundation Models採用）・ADR-005（actor設計）を確認する
3. `BakusokuMemoApp/Generable/` と `BakusokuMemoApp/Features/` の既存ファイルを確認する

### Step 2: @Generable 構造体の実装

`BakusokuMemoApp/Generable/[名前].swift` を作成：

```swift
import FoundationModels

@Generable
struct [名前] {
    @Guide(description: "[プロパティの意図を日本語で明示]")
    var [property]: [Type]
    // 選択肢が固定なら @Generable enum を使う
}

// 選択肢が固定の場合
@Generable
enum [EnumName]: String {
    case [case1]
    case [case2]
}
```

**必須チェック**:

- 全プロパティに `@Guide(description:)` を付与する（省略禁止）
- raw `String` 型の AI 出力を受け取らない
- フォールバック用の代替型を定義しない

### ✅ バリデーションゲート 2: @Generable 定義チェック

actor の実装に進む前に以下を確認する。❌があれば修正する。

- [ ] 全プロパティに `@Guide(description:)` が付いている
- [ ] `String` 素の AI 出力を直接受け化するプロパティがない
- [ ] フォールバック用のオプショナル型・代替型が定義されていない

### Step 3: actor の実装

`BakusokuMemoApp/Features/[名前].swift` を作成：

```swift
import FoundationModels

actor [名前] {
    func [method](_ input: String) async throws -> [Generable型] {
        // 1. availability チェック（必須）
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(let reason):
            throw [Error].appleIntelligenceUnavailable(reason)
        }

        // 2. セッションを毎回新規生成（使い捨て）
        let session = LanguageModelSession(
            instructions: Instructions("[システムプロンプト]")
        )

        // 3. 構造化出力で受け取る
        let response = try await session.respond(
            to: Prompt(input),
            generating: [Generable型].self
        )
        return response.content
    }
}
```

**必須チェック**:

- `SystemLanguageModel.default.availability` チェックを先頭に置く
- `LanguageModelSession` をプロパティとして保持しない（毎回 `init`）
- `.unavailable` 時にフォールバック処理を書かない（エラーを throw するだけ）
- `@Model` インスタンスを actor 境界を越えて渡さない（`UUID` などプリミティブ値のみ渡す）

### ✅ バリデーションゲート 3: actor 実装チェック

エラー型定義に進む前に以下を確認する。かひとつでも ❌ なら修正する。

- [ ] `availability` チェックがメソッドの先頭にある
- [ ] `LanguageModelSession` が `actor` のプロパティとして保持されていない
- [ ] `.unavailable` ブランチにルールベース・正規表現・外部 API 呼び出しがない
- [ ] `@Model` インスタンスを actor 境界を越えて渡していない

### Step 4: エラー型の定義

`BakusokuMemoApp/Features/[名前]Error.swift` を作成（未定義なら）：

```swift
import FoundationModels

enum [名前]Error: Error, LocalizedError {
    case appleIntelligenceUnavailable(SystemLanguageModel.Availability.UnavailableReason)
    case contextWindowExceeded
    case unsupportedLanguage

    var errorDescription: String? {
        switch self {
        case .appleIntelligenceUnavailable:
            return "Apple Intelligence が利用できません。設定から有効にしてください。"
        case .contextWindowExceeded:
            return "テキストが長すぎます。短くしてもう一度お試しください。"
        case .unsupportedLanguage:
            return "この言語には対応していません。"
        }
    }
}
```

### Step 5: prewarm の呼び出し（初回実装時）

`BakusokuMemoApp/App/BakusokuMemoApp.swift` に起動時 prewarm を追加する（まだなければ）：

```swift
.task {
    Task.detached(priority: .background) {
        let session = LanguageModelSession(
            instructions: Instructions("ユーザーが入力した日本語テキストを分析・整形してください。")
        )
        await session.prewarm(promptPrefix: Prompt(""))
    }
}
```

### Step 6: 問題チェック・progress 更新

`read/problems` で Swift 6 concurrency 違反を確認し、`memory/progress.md` を更新する。

### ✅ バリデーションゲート 4: 完了確認

`memory/progress.md` を更新する前に以下をすべて確認する。満たさない項目があれば修正してから更新する。

- [ ] `read/problems` に Swift 6 concurrency エラーがない
- [ ] `availability` チェックが実当する全メソッドに存在する
- [ ] `LanguageModelSession` がプロパティとして保持されていない（`init` がメソッド内にある）
- [ ] フォールバック処理がコードに混入していない
