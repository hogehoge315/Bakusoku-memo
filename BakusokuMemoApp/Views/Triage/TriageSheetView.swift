import SwiftUI
import SwiftData

/// トリアージオーバーレイ（ふわっと浮くカード）。
/// `.sheet` ではなく ZStack overlay として親ビューに埋め込む。
struct TriageSheetView: View {

    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \PendingMemo.createdAt)
    private var pendingMemos: [PendingMemo]

    @State private var currentIndex: Int = 0

    private var currentMemo: PendingMemo? {
        guard pendingMemos.indices.contains(currentIndex) else { return nil }
        return pendingMemos[currentIndex]
    }

    var body: some View {
        ZStack {
            // スクリム
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { close() }

            // フローティングカード
            VStack(spacing: 0) {
                // ヘッダー（青グラデーション）
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("トリアージ")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        if !pendingMemos.isEmpty {
                            Text("\(min(currentIndex + 1, pendingMemos.count)) / \(pendingMemos.count) 件")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    Spacer()
                    Button { close() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(.white.opacity(0.2), in: Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.4, blue: 0.95), .indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // コンテンツ
                if let memo = currentMemo {
                    TriageCardView(
                        memo: memo,
                        onRegister: { advance() },
                        onSkip: { advance() },
                        onDiscard: {
                            modelContext.delete(memo)
                            advance()
                        }
                    )
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.green)
                        Text("すべて処理しました")
                            .font(.headline)
                        Text("保留メモはありません")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("閉じる") { close() }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 32, y: 12)
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
        }
    }

    private func close() {
        withAnimation(.spring(duration: 0.3)) {
            isPresented = false
        }
    }

    private func advance() {
        if currentIndex < pendingMemos.count - 1 {
            withAnimation(.spring(duration: 0.3)) {
                currentIndex += 1
            }
        } else {
            close()
        }
    }
}
