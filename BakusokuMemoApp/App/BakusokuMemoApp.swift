import SwiftUI
import SwiftData
import FoundationModels

@main
struct BakusokuMemoApp: App {

    let container: ModelContainer = {
        let schema = Schema([
            Thread.self,
            ThreadItem.self,
            PendingMemo.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer の初期化に失敗しました: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentRootView()
        }
        .modelContainer(container)
    }
}
