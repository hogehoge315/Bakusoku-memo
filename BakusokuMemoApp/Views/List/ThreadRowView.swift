import SwiftUI

/// スレッド一覧の行コンポーネント（LINEトーク風）。
struct ThreadRowView: View {

    let thread: Thread

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // アイコン
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.18), .indigo.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Text(thread.title.prefix(1))
                    .font(.headline.bold())
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .indigo], startPoint: .top, endPoint: .bottom)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(thread.title)
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    if thread.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(thread.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                HStack {
                    Text(
                        thread.markdownContent.isEmpty
                            ? "（未整理）"
                            : thread.markdownContent
                                .replacingOccurrences(of: "#", with: "")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                    Spacer()

                    if thread.isProcessing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .tint(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
