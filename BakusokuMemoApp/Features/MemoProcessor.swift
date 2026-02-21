import Foundation
import SwiftData
import SwiftUI

// MARK: - Toast メッセージ

struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    let icon: String
    let tint: Color
}

// MARK: - MemoProcessor

/// InputView から AI 整形フローを駆動する Observable。
/// @MainActor で SwiftData / UI 更新を安全に行う。
@Observable
@MainActor
final class MemoProcessor {

    var toast: ToastItem? = nil
    var isProcessing: Bool = false

    private let formatter = ThreadFormatter()

    /// メモを送信し、AI整形 → Thread 統合 を行う。
    /// AI が利用できない場合は PendingMemo として保存する。
    func submit(rawText: String, context: ModelContext, existingThreads: [Thread]) async {
        guard !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isProcessing = true
        showToast("AIが整理中…", icon: "sparkles", tint: .purple)

        do {
            // Step 1: スレッド候補を取得
            let titles = existingThreads.map { $0.title }
            let suggestion = try await formatter.suggestThreads(rawText: rawText, existingTitles: titles)
            let targetTitle = suggestion.suggestions.first ?? String(rawText.prefix(20))

            // Step 2: 既存スレッドに統合 or 新規作成
            if let existing = existingThreads.first(where: { $0.title == targetTitle }) {
                existing.isProcessing = true
                let result = try await formatter.integrateNewMemo(
                    threadId: existing.id,
                    existingTitle: existing.title,
                    existingMarkdown: existing.markdownContent,
                    newMemo: rawText
                )
                existing.markdownContent = result.markdownContent
                existing.updatedAt = Date()
                existing.isProcessing = false

                let item = ThreadItem(threadId: existing.id, rawText: rawText, itemType: .memo)
                context.insert(item)
                existing.items.append(item)

                showToast("「\(existing.title)」に追加しました", icon: "checkmark.circle.fill", tint: .green)
            } else {
                let result = try await formatter.integrateNewMemo(
                    threadId: UUID(),
                    existingTitle: targetTitle,
                    existingMarkdown: "",
                    newMemo: rawText
                )
                let thread = Thread(title: result.title, markdownContent: result.markdownContent)
                context.insert(thread)

                let item = ThreadItem(threadId: thread.id, rawText: rawText, itemType: .memo)
                context.insert(item)
                thread.items.append(item)

                showToast("「\(result.title)」を作成しました", icon: "checkmark.circle.fill", tint: .green)
            }

        } catch ThreadFormatterError.appleIntelligenceUnavailable {
            // シミュレーター または Apple Intelligence 未設定 → 保留リストへ
            let memo = PendingMemo(rawText: rawText)
            context.insert(memo)
            showToast("保留リストに追加しました（AI未対応環境）", icon: "tray.fill", tint: .orange)

        } catch ThreadFormatterError.contextWindowExceeded {
            let memo = PendingMemo(rawText: rawText)
            context.insert(memo)
            showToast("テキストが長すぎます。保留リストへ移動しました", icon: "exclamationmark.circle.fill", tint: .red)

        } catch {
            let memo = PendingMemo(rawText: rawText)
            context.insert(memo)
            showToast("エラーが発生しました。保留リストへ移動しました", icon: "exclamationmark.circle.fill", tint: .red)
        }

        isProcessing = false
    }

    // MARK: - Private

    private func showToast(_ message: String, icon: String, tint: Color) {
        withAnimation(.spring(duration: 0.4)) {
            toast = ToastItem(message: message, icon: icon, tint: tint)
        }
        Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.spring(duration: 0.4)) {
                toast = nil
            }
        }
    }
}
