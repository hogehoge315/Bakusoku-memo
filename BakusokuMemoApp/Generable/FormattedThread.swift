import FoundationModels

/// スレッドのMarkdown再生成レスポンス型。
@Generable
struct FormattedThread {

    /// スレッドタイトル（新規作成時のみAIが命名。既存スレッドは変更しない）
    @Guide(description: "スレッドのタイトル。新規作成時のみ生成する。既存スレッドはそのまま返す。")
    var title: String

    /// 整形後のMarkdownコンテンツ
    @Guide(description: "整形後のMarkdown本文。変更最小化・セクション単位で更新すること。")
    var markdownContent: String
}
