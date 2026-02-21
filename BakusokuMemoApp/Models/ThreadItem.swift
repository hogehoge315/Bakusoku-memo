import Foundation
import SwiftData

/// スレッド内の元メモ履歴 または AI指示ログ
@Model
final class ThreadItem {

    enum ItemType: String, Codable {
        case memo
        case aiInstruction
    }

    var id: UUID
    var threadId: UUID
    var rawText: String
    var itemType: ItemType
    var createdAt: Date

    var thread: Thread?

    init(
        id: UUID = UUID(),
        threadId: UUID,
        rawText: String,
        itemType: ItemType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.threadId = threadId
        self.rawText = rawText
        self.itemType = itemType
        self.createdAt = createdAt
    }
}
