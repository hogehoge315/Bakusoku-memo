import Foundation
import SwiftData

/// スレッド（AIが管理するMarkdownベースのメモグループ）
@Model
final class Thread {

    var id: UUID
    var title: String
    var markdownContent: String
    var isLocked: Bool
    var isProcessing: Bool
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ThreadItem.thread)
    var items: [ThreadItem]

    init(
        id: UUID = UUID(),
        title: String,
        markdownContent: String = "",
        isLocked: Bool = false,
        isProcessing: Bool = false,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.markdownContent = markdownContent
        self.isLocked = isLocked
        self.isProcessing = isProcessing
        self.updatedAt = updatedAt
        self.items = []
    }
}
