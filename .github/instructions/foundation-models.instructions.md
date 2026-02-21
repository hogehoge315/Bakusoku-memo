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
        throw ThreadFormatterError.appleIntelligenceUnavailable(reason)
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
struct ThreadSuggestion {
    @Guide(description: "候補スレッドのタイトル（10文字以内）")
    var title: String

    @Guide(description: "候補の理由や関連性を短く説明")
    var reason: String
}

// Markdown再生成レスポンス
@Generable
struct FormattedThread {
    @Guide(description: "既存コンテンツに新メモを統合したMarkdown全文")
    var markdownContent: String
}
```

### LanguageModelSession の使い方

- **セッションはリクエストごとに生成する（使い捨て）**
- `Instructions` は session init 時に渡す（後から変更不可）
- `actor` 内に session を保持しない（毎回 `init` する）

```swift
actor ThreadFormatter {
    func suggestThreads(rawText: String) async throws -> ThreadSuggestion {
        // ✅ リクエストごとに新規セッション
        let session = LanguageModelSession(
            instructions: Instructions(
                "ユーザーが入力した日本語テキストに最も適したスレッド候補を返してください。"
            )
        )
        let response = try await session.respond(
            to: Prompt(rawText),
            generating: ThreadSuggestion.self
        )
        return response.content
    }
}
```

### エラーハンドリング

代替処理なし。ユーザーへの通知のみ行う。

```swift
enum ThreadFormatterError: Error {
    case appleIntelligenceUnavailable(SystemLanguageModel.Availability.UnavailableReason)
    case contextWindowExceeded
    case unsupportedLanguage
}

// catch 側
do {
    let result = try await formatter.suggestThreads(rawText: input)
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
