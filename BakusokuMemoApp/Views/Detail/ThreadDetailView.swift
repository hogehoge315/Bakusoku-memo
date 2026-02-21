import SwiftUI

/// スレッド詳細画面（Markdownプレビュー・編集・AI指示）。
/// Phase 5 で本実装予定。
struct ThreadDetailView: View {

    @Bindable var thread: Thread
    @State private var isEditing: Bool = false

    var body: some View {
        Group {
            if isEditing {
                TextEditor(text: $thread.markdownContent)
                    .padding()
            } else {
                ScrollView {
                    Text(thread.markdownContent.isEmpty ? "（内容なし）" : thread.markdownContent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        thread.isLocked.toggle()
                    } label: {
                        Image(systemName: thread.isLocked ? "lock.fill" : "lock.open")
                    }

                    Button(isEditing ? "完了" : "編集") {
                        isEditing.toggle()
                    }
                    .disabled(thread.isProcessing)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            MemoHistoryView(thread: thread)
        }
    }
}
