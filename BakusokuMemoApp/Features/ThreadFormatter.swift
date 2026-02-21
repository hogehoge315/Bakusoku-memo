import Foundation
import FoundationModels

// MARK: - エラー定義

enum ThreadFormatterError: Error, LocalizedError {
    case appleIntelligenceUnavailable
    case contextWindowExceeded

    var errorDescription: String? {
        switch self {
        case .appleIntelligenceUnavailable:
            return "Apple Intelligence が利用できません。対応デバイスで試してください。"
        case .contextWindowExceeded:
            return "テキストが長すぎます。短くして再試行してください。"
        }
    }
}

// MARK: - ThreadFormatter

/// AI整形処理を隔離する actor。
/// SwiftData 操作は @MainActor 側で行う。このacto境界を越えるのはプリミティブ値のみ。
actor ThreadFormatter {

    // MARK: バブル候補生成

    /// 入力テキストから既存スレッドのタイトル候補を最大3件返す。
    /// - Parameters:
    ///   - rawText: ユーザーが入力した生テキスト
    ///   - existingTitles: 既存スレッドのタイトル一覧
    func suggestThreads(rawText: String, existingTitles: [String]) async throws -> ThreadSuggestion {
        try checkAvailability()

        let titlesText = existingTitles.isEmpty
            ? "（既存スレッドなし）"
            : existingTitles.map { "- \($0)" }.joined(separator: "\n")

        let session = LanguageModelSession(
            instructions: Instructions("""
            ユーザーが入力した日本語メモを既存スレッドに分類してください。
            最も関連性が高いスレッドのタイトルを最大3件、配列で返してください。
            既存スレッドがない場合は新規作成候補のタイトルを提案してください。
            タイトルは15文字以内で簡潔に。
            """)
        )

        let prompt = """
        ## 入力メモ
        \(rawText)

        ## 既存スレッド
        \(titlesText)
        """

        do {
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: ThreadSuggestion.self
            )
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw ThreadFormatterError.contextWindowExceeded
        }
    }

    // MARK: スレッド統合

    /// 既存Markdownと新メモを統合してMarkdownを再生成する。
    /// - Parameters:
    ///   - threadId: 対象スレッドのID（actor境界を越えるためUUIDで渡す）
    ///   - existingTitle: 既存スレッドのタイトル
    ///   - existingMarkdown: 既存のMarkdownコンテンツ（空文字なら新規）
    ///   - newMemo: 追加する新規メモのテキスト
    func integrateNewMemo(
        threadId: UUID,
        existingTitle: String,
        existingMarkdown: String,
        newMemo: String
    ) async throws -> FormattedThread {
        try checkAvailability()

        let isNew = existingMarkdown.isEmpty

        let session = LanguageModelSession(
            instructions: Instructions("""
            あなたはメモ整理AIです。ユーザーの新しいメモを既存のMarkdownスレッドに統合してください。
            変更は最小化し、セクション単位で更新してください。
            大幅な変更が必要な場合のみ全体を再構成してください。
            タイトルは変更しないでください（新規スレッドの場合は適切なタイトルを生成してください）。
            日本語で出力してください。
            """)
        )

        let prompt = isNew ? """
        ## 新規スレッド作成
        以下のメモを整理してMarkdownスレッドを新規作成してください。

        ## メモ
        \(newMemo)
        """ : """
        ## 既存スレッド
        タイトル: \(existingTitle)

        \(existingMarkdown)

        ## 追加するメモ
        \(newMemo)
        """

        do {
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: FormattedThread.self
            )
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw ThreadFormatterError.contextWindowExceeded
        }
    }

    // MARK: AI指示処理

    /// ユーザーのAI指示でMarkdownを更新する。
    /// - Parameters:
    ///   - threadId: 対象スレッドのID
    ///   - currentTitle: 現在のスレッドタイトル
    ///   - currentMarkdown: 現在のMarkdownコンテンツ
    ///   - instruction: ユーザーからのAI指示テキスト
    func applyInstruction(
        threadId: UUID,
        currentTitle: String,
        currentMarkdown: String,
        instruction: String
    ) async throws -> FormattedThread {
        try checkAvailability()

        let session = LanguageModelSession(
            instructions: Instructions("""
            ユーザーの指示に従ってMarkdownスレッドを更新してください。
            タイトルは変更しないでください。
            日本語で出力してください。
            """)
        )

        let prompt = """
        ## 現在のスレッド
        タイトル: \(currentTitle)

        \(currentMarkdown)

        ## ユーザーの指示
        \(instruction)
        """

        do {
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: FormattedThread.self
            )
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            throw ThreadFormatterError.contextWindowExceeded
        }
    }

    // MARK: - Private

    private func checkAvailability() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            break
        case .unavailable(_):
            throw ThreadFormatterError.appleIntelligenceUnavailable
        }
    }
}
