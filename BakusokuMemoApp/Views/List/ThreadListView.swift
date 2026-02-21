import SwiftUI
import SwiftData

/// スレッド一覧画面。
struct ThreadListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thread.updatedAt, order: .reverse)
    private var threads: [Thread]

    @Query(sort: \PendingMemo.createdAt, order: .reverse)
    private var pendingMemos: [PendingMemo]

    @State private var searchText: String = ""
    @State private var showTriage: Bool = false

    private var filteredThreads: [Thread] {
        guard !searchText.isEmpty else { return threads }
        return threads.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.markdownContent.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            NavigationStack {
                Group {
                    if threads.isEmpty && pendingMemos.isEmpty {
                        ContentUnavailableView(
                            "スレッドなし",
                            systemImage: "text.bubble",
                            description: Text("左の入力画面からメモを投げましょう")
                        )
                    } else {
                        List {
                            if !pendingMemos.isEmpty {
                                Section {
                                    Button {
                                        showTriage = true
                                    } label: {
                                        HStack(spacing: 14) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.orange, .red.opacity(0.8)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 38, height: 38)
                                                Image(systemName: "tray.full.fill")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundStyle(.white)
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("未分類メモ")
                                                    .font(.subheadline.bold())
                                                    .foregroundStyle(.primary)
                                                Text("\(pendingMemos.count)件のメモがスレッドを待っています")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption.bold())
                                                .foregroundStyle(.tertiary)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }

                            Section {
                                ForEach(filteredThreads) { thread in
                                    NavigationLink {
                                        ThreadDetailView(thread: thread)
                                    } label: {
                                        ThreadRowView(thread: thread)
                                    }
                                }
                                .onDelete(perform: deleteThreads)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .searchable(text: $searchText, prompt: "スレッドを検索")
                .navigationTitle("スレッド")
            }

            // フローティングトリアージオーバーレイ
            if showTriage {
                TriageSheetView(isPresented: $showTriage)
                    .transition(.opacity.combined(with: .scale(scale: 0.94, anchor: .center)))
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.1), value: showTriage)
    }

    private func deleteThreads(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredThreads[index])
        }
    }
}

#Preview {
    ThreadListView()
        .modelContainer(for: [Thread.self, ThreadItem.self, PendingMemo.self], inMemory: true)
}
