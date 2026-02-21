import Foundation
import SwiftData

/// トリアージ待ちの保留メモ
@Model
final class PendingMemo {

    var id: UUID
    var rawText: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        rawText: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.rawText = rawText
        self.createdAt = createdAt
    }
}
