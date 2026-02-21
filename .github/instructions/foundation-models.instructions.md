---
applyTo: "**/Features/**/*.swift,**/Generable/**/*.swift"
---

## Foundation Models 実装規約

> **原則**: Apple Intelligence はアプリの前提条件。フォールバック実装は一切書かない。

### availability チェック（必須）

Foundation Models を呼ぶ前に必ず `SystemLanguageModel.default.availability` を確認する。
`.unavailable` の場合はエラーを throw するだけ。代替処理を書かない。

```swift
// OK
func format(rawText: String) async throws -> FormattedMemo {
    switch SystemLanguageModel.default.availability {
    case .available:
        break
    case .unavailable(let reason):
        throw MemoFormatterError.appleIntelligenceUnavailable(reason)
    }
    // 以降の処理...
}

// NG — フォールバック実装
case .unavailable:
    return ruleBasedFormat(rawText) // ← 絶対に書かない
```

### @Generable 構造体の定義

- `@Generable` マクロを付与する
- 全プロパティに `@Guide(description:)` で AI への意図を明示する
- 選択肢が固定の場合は `@Generable` な `enum` を使う

```swift
import FoundationModels

@Generable
struct FormattedMemo {
    @Guide(description: "メモの種類。買い物リストなら shopping、タスクや TODO なら todo、その他は note")
    var memoType: MemoType

    @Guide(description: "整形・分割されたアイテムの配列。入力テキストを意味のある最小単位に分割する。例: [\"髭剃り\", \"コンタクト液\", \"歯ブラシ\"]")
    var items: [String]

    @Guide(description: "メモ全体を表すタイトル（10文字以内、体言止め）")
    var title: String
}

@Generable
enum MemoType: String {
    case shopping
    case todo
    case note
}
```

### LanguageModelSession の使い方

- **セッションはリクエストごとに生成する（使い捨て）**
- `Instructions` は session init 時に渡す（後から変更不可）
- `actor` 内に session を保持しない（毎回 `init` する）

```swift
actor MemoFormatter {
    func format(rawText: String) async throws -> FormattedMemo {
        // ✅ リクエストごとに新規セッション
        let session = LanguageModelSession(
            instructions: Instructions(
                "ユーザーが入力した日本語の雑然としたテキストを分析し、種類を判定して適切な形式に整形してください。"
            )
        )
        let response = try await session.respond(
            to: Prompt(rawText),
            generating: FormattedMemo.self
        )
        return response.content
    }
}
```

### エラーハンドリング

代替処理なし。ユーザーへの通知のみ行う。

```swift
enum MemoFormatterError: Error {
    case appleIntelligenceUnavailable(SystemLanguageModel.Availability.UnavailableReason)
    case contextWindowExceeded
    case unsupportedLanguage
}

// catch 側
do {
    let result = try await formatter.format(rawText: input)
} catch GenerationError.exceededContextWindowSize {
    // UI に「テキストが長すぎます」を表示するだけ
} catch GenerationError.unsupportedLanguageOrLocale {
    // UI に「この言語は対応していません」を表示するだけ
}
```

### 起動レイテンシ削減（prewarm）

アプリ起動後バックグラウンドで `prewarm` を呼んでモデルをウォームアップする。

```swift
Task.detached(priority: .background) {
    let session = LanguageModelSession(instructions: Instructions("..."))
    await session.prewarm(promptPrefix: Prompt(""))
}
```

### 禁止事項

- raw `String` で AI の出力を受け取らない（必ず `@Generable` 型で受け取る）
- `LanguageModelSession` をキャッシュしない
- `SystemLanguageModel.default.availability` チェックをスキップしない
- `.unavailable` 時にフォールバック処理（ルールベース・正規表現等）を書かない
- `@Generable` プロパティへの `@Guide` を省略しない
