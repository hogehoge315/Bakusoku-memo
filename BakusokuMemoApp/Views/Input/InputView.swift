import SwiftUI
import SwiftData

/// 入力画面（デフォルト画面）。
/// キーボード自動ON・送信で確定・AI処理を MemoProcessor に委譲。
struct InputView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PendingMemo.createdAt, order: .reverse)
    private var pendingMemos: [PendingMemo]
    @Query(sort: \Thread.updatedAt, order: .reverse)
    private var threads: [Thread]

    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    @State private var showTriage: Bool = false
    @State private var processor = MemoProcessor()
    @State private var submittedBubbles: [SubmittedBubble] = []

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .top) {
                    ScrollView {
                        contentArea
                            .padding(.bottom, 24)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .safeAreaInset(edge: .bottom) {
                        inputBar
                    }

                    // トーストオーバーレイ
                    if let toast = processor.toast {
                        ToastView(toast: toast)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 8)
                            .zIndex(10)
                    }
                }
                .animation(.spring(duration: 0.4), value: processor.toast?.id)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("爆速メモ")
                            .font(.headline.bold())
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if !pendingMemos.isEmpty {
                            Button {
                                showTriage = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "tray.fill")
                                        .font(.body)
                                    Text("\(pendingMemos.count)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(3)
                                        .background(.orange, in: Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                            .foregroundStyle(.orange)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear {
                isFocused = true
            }

            // フローティングトリアージオーバーレイ
            if showTriage {
                TriageSheetView(isPresented: $showTriage)
                    .transition(.opacity.combined(with: .scale(scale: 0.94, anchor: .center)))
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.1), value: showTriage)
    }

    // MARK: - コンテンツエリア

    @ViewBuilder
    private var contentArea: some View {
        if threads.isEmpty && pendingMemos.isEmpty {
            emptyStateView
        } else {
            VStack(spacing: 0) {
                // 送信済みバブル（アニメーション）
                if !submittedBubbles.isEmpty {
                    submittedBubbleList
                }
                recentSummaryView
            }
        }
    }

    // MARK: 空状態

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.25), .indigo.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )
            }

            Spacer().frame(height: 28)

            Text("思考の速度で投げる")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("AIが自動でスレッドに整理します")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 6)

            Spacer().frame(height: 40)

            VStack(spacing: 0) {
                stepRow(number: "1", title: "入力", description: "下のエリアにメモを書く")
                stepDivider
                stepRow(number: "2", title: "送信", description: "↑ボタンで即時確定")
                stepDivider
                stepRow(number: "3", title: "AI整理", description: "バックグラウンドで自動分類")
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }

    private var stepDivider: some View {
        HStack {
            Spacer().frame(width: 52)
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 1, height: 20)
            Spacer()
        }
    }

    private func stepRow(number: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: 送信済みバブル

    private var submittedBubbleList: some View {
        VStack(alignment: .trailing, spacing: 6) {
            ForEach(submittedBubbles) { bubble in
                HStack {
                    Spacer()
                    Text(bubble.text)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.tint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.trailing, 16)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .padding(.top, 12)
        .animation(.spring(duration: 0.4), value: submittedBubbles.count)
    }

    // MARK: 最近のスレッド

    private var recentSummaryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近のスレッド")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            ForEach(threads.prefix(5)) { thread in
                NavigationLink(destination: ThreadDetailView(thread: thread)) {
                    RecentThreadCard(thread: thread)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - 入力バー

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 10) {
                ZStack(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text("メモを投げる…")
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $inputText)
                        .font(.body)
                        .focused($isFocused)
                        .frame(minHeight: 40, maxHeight: 120)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isFocused ? Color.blue.opacity(0.7) : Color(.separator),
                            lineWidth: isFocused ? 2 : 1
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }

                sendButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.regularMaterial)
        }
    }

    private var sendButton: some View {
        let canSend = !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !processor.isProcessing
        return Button(action: submitMemo) {
            ZStack {
                Circle()
                    .fill(
                        canSend
                        ? LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(.systemFill), Color(.systemFill)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 36, height: 36)

                if processor.isProcessing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.75)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(canSend ? .white : Color(.tertiaryLabel))
                }
            }
            .animation(.spring(duration: 0.2), value: canSend)
            .animation(.spring(duration: 0.2), value: processor.isProcessing)
        }
        .disabled(!canSend)
    }

    // MARK: - Actions

    private func submitMemo() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // バブルアニメーション用に記録
        let bubble = SubmittedBubble(text: String(text.prefix(60)))
        withAnimation { submittedBubbles.insert(bubble, at: 0) }

        // バブルを3秒後に消す
        Task {
            try? await Task.sleep(for: .seconds(4))
            withAnimation {
                submittedBubbles.removeAll { $0.id == bubble.id }
            }
        }

        inputText = ""
        isFocused = true

        // AI処理に委譲
        let threadsSnapshot = Array(threads)
        Task {
            await processor.submit(
                rawText: text,
                context: modelContext,
                existingThreads: threadsSnapshot
            )
        }
    }
}

// MARK: - サブビュー

/// 送信済みバブルのデータモデル
private struct SubmittedBubble: Identifiable {
    let id = UUID()
    let text: String
}

/// 最近のスレッドカード
private struct RecentThreadCard: View {
    let thread: Thread

    // Markdown 記号を除去して最初の有効行を返す
    private var previewText: String {
        thread.markdownContent
            .components(separatedBy: "\n")
            .compactMap { line -> String? in
                let s = line.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "^#{1,6}\\s*", with: "", options: .regularExpression)
                    .replacingOccurrences(of: "^[-*+]\\s+", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                return s.isEmpty ? nil : s
            }
            .first ?? ""
    }

    var body: some View {
        HStack(spacing: 12) {
            // アクセントバー（青）
            Capsule()
                .fill(
                    thread.isLocked
                    ? LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [.blue, .indigo], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 3, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(thread.title)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    if thread.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                if !previewText.isEmpty {
                    Text(previewText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if thread.isProcessing {
                ProgressView()
                    .scaleEffect(0.75)
                    .tint(.blue)
            } else {
                Text(thread.updatedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// トースト通知ビュー
struct ToastView: View {
    let toast: ToastItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.icon)
                .foregroundStyle(toast.tint)
                .font(.subheadline.bold())
            Text(toast.message)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }
}

#Preview {
    InputView()
        .modelContainer(for: [Thread.self, ThreadItem.self, PendingMemo.self], inMemory: true)
}
