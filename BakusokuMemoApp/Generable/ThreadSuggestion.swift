import FoundationModels

/// バブル候補・トリアージ候補のAI出力型。
/// 既存スレッドのタイトル候補を最大3件返す。
@Generable
struct ThreadSuggestion {

    /// スレッドタイトル候補（最大3件）
    @Guide(description: "既存スレッドのタイトル候補。最大3件。")
    var suggestions: [String]
}
