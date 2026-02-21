import SwiftUI

/// ルートView。
/// index 0: 入力画面（デフォルト）↔ index 1: スレッド一覧
/// 左右スワイプでページ遷移。ページインジケーター付き。
struct RootView: View {

    @State private var selection: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                InputView()
                    .tag(0)
                ThreadListView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // ページインジケーター（safe area 内）
            HStack(spacing: 8) {
                ForEach(0..<2) { index in
                    Capsule()
                        .fill(selection == index ? Color.primary : Color(.tertiaryLabel))
                        .frame(width: selection == index ? 20 : 6, height: 6)
                        .animation(.spring(duration: 0.3), value: selection)
                        .onTapGesture { selection = index }
                }
            }
            .padding(.bottom, 4)
            .padding(.horizontal)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Thread.self, ThreadItem.self, PendingMemo.self], inMemory: true)
}
