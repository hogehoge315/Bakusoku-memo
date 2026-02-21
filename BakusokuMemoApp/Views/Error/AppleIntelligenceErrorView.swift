import SwiftUI

/// Apple Intelligence が利用できない場合のエラー画面。
/// フォールバック実装は一切提供しない（ADR-003）。
struct AppleIntelligenceErrorView: View {

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundStyle(.orange)
                }

                VStack(spacing: 8) {
                    Text("Apple Intelligence が必要です")
                        .font(.title2.bold())
                    Text("このアプリは Apple Intelligence に対応した\nデバイス（iPhone 15 Pro 以降）でのみ動作します。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            VStack(spacing: 12) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("設定を開く", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)

                Text("Apple Intelligence が有効になると\n自動で起動します")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }
}

#Preview {
    AppleIntelligenceErrorView()
}
