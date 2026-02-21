import SwiftUI
import SwiftData

/// 元メモ履歴（デフォルト畳まれ・タップで展開）。
struct MemoHistoryView: View {

    let thread: Thread

    @State private var isExpanded: Bool = false

    private var sortedItems: [ThreadItem] {
        thread.items.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Spacer()

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("履歴")
                        .font(.caption.bold())
                        .padding(.horizontal)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(sortedItems) { item in
                                historyRow(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
                .transition(.move(edge: .bottom))
            }

            Button {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down.circle.fill" : "clock.arrow.circlepath")
                    .font(.title2)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(Circle())
            }
            .padding(.trailing)
        }
    }

    @ViewBuilder
    private func historyRow(item: ThreadItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: item.itemType == .memo ? "note.text" : "wand.and.stars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(item.itemType == .memo ? "メモ" : "AI指示")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Text(item.rawText)
                .font(.caption)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
