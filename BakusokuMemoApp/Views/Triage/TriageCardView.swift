import SwiftUI

/// トリアージカード（スワイプ + アクションボタン）。
struct TriageCardView: View {

    let memo: PendingMemo
    let onRegister: () -> Void
    let onSkip: () -> Void
    let onDiscard: () -> Void

    @State private var dragOffset: CGSize = .zero

    private var dragX: CGFloat { dragOffset.width }
    private var dragY: CGFloat { dragOffset.height }

    private var swipeColor: Color? {
        if dragX > 40 { return .green }
        if dragX < -40 { return .red }
        if dragY < -40 { return .blue }
        return nil
    }

    private var swipeIcon: String {
        if dragX > 40 { return "checkmark.circle.fill" }
        if dragX < -40 { return "trash.fill" }
        if dragY < -40 { return "arrow.up.circle.fill" }
        return ""
    }

    var body: some View {
        VStack(spacing: 20) {
            // スワイプカード
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))

                ScrollView {
                    Text(memo.rawText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                }
                .frame(maxHeight: 180)

                // スワイプフィードバック
                if let color = swipeColor {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(color.opacity(0.2))
                    Image(systemName: swipeIcon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(color)
                        .shadow(radius: 4)
                }
            }
            .frame(height: 180)
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragX) / 18), anchor: .bottom)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let x = value.translation.width
                        let y = value.translation.height
                        withAnimation(.spring(duration: 0.35)) {
                            dragOffset = .zero
                        }
                        if x > 80 { onRegister() }
                        else if x < -80 { onDiscard() }
                        else if y < -80 { onSkip() }
                    }
            )
            .animation(.interactiveSpring(response: 0.3), value: dragOffset)

            // アクションボタン
            HStack(spacing: 28) {
                triageButton(icon: "trash", label: "廃棄", color: .red, action: onDiscard)
                triageButton(icon: "arrow.up", label: "スキップ", color: .blue, action: onSkip)
                triageButton(icon: "checkmark", label: "登録", color: .green, action: onRegister)
            }
            .padding(.bottom, 4)
        }
        .padding(20)
    }

    private func triageButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.13))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.caption.bold())
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}
