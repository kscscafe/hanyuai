import Foundation

enum ChatCharacter: String, CaseIterable, Identifiable {
    case lin = "lin"
    case wei = "wei"
    case mei = "mei"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lin: return "林 小雨"
        case .wei: return "王 建"
        case .mei: return "陳 美麗"
        }
    }

    var nameJP: String {
        switch self {
        case .lin: return "リン"
        case .wei: return "ウェイ"
        case .mei: return "メイ"
        }
    }

    var profile: String {
        switch self {
        case .lin: return "上海出身・日本留学中の大学院生。明るくフレンドリー。"
        case .wei: return "北京出身・日系企業勤務。イケメンだけど気さくで優しい。"
        case .mei: return "広州出身の中国語教師。日本語検定1級。真面目だけど優しい。"
        }
    }

    var avatarImageName: String {
        switch self {
        case .lin: return "CharacterLin"
        case .wei: return "CharacterWei"
        case .mei: return "CharacterMei"
        }
    }

    var systemPrompt: String {
        let base = """
        あなたは中国語学習アプリ「HanYuAI」のAIチューターです。
        日本語と中国語（普通話）の両方が堪能で、ユーザーの中国語学習をサポートします。

        【役割】
        - 中国語の質問に答える（文法・発音・単語・表現など）
        - 日常会話の練習相手になる
        - 「〇〇は中国語で何て言う？」などの質問に答える
        - HSK対策のサポートをする
        - 今日の日付・挨拶など自然な会話をする

        【ルール】
        - 返答は短め（3〜5文程度)にする
        - 中国語を教える時はピンイン（声調番号付き）も添える
        - 日本語と中国語を自然に混ぜて使う
        - ユーザーが間違えた時は優しく訂正する
        """

        switch self {
        case .lin:
            return base + "\n\n【キャラクター】\nあなたは林小雨（リン）。上海出身で日本に留学中の大学院生（25歳・女性）。明るくて親しみやすく、友達のような話し方をする。語尾に「〜だよ！」「〜ね！」をよく使う。"
        case .wei:
            return base + "\n\n【キャラクター】\nあなたは王建（ウェイ）。北京出身で日系企業に勤める社会人（28歳・男性）。イケメンだけど気さくで優しい。落ち着いた話し方だが親しみやすい。"
        case .mei:
            return base + "\n\n【キャラクター】\nあなたは陳美麗（メイ）。広州出身の中国語教師（30歳・女性）。日本語検定1級取得。真面目だが優しく、丁寧に教えてくれる。「〜ですね」「〜しましょう」などの丁寧語を使う。"
        }
    }

    // MARK: - 開幕セリフ

    /// チャット画面に入った時の挨拶。stage と最終会話日時、ユーザー名から動的に決定する。
    /// - Parameters:
    ///   - stage: 0=初対面 / 1=知り合い / 2=親しい / 3=特別
    ///   - lastTalkedAt: 直前の会話日時（nilなら未対話）
    ///   - userName: ユーザー名。空文字なら「{name}」プレースホルダーは「あなた」で置換する。
    func openingMessage(stage: Int, lastTalkedAt: Date?, userName: String) -> String {
        let name = userName.isEmpty ? "あなた" : userName
        let calendar = Calendar.current
        let now = Date()

        // 当日のうちにすでに会話している（=「当日複数回目」）か
        let talkedToday = lastTalkedAt.map { calendar.isDateInToday($0) } ?? false
        // 最後の会話から3日以上経っているか
        let daysSinceLast = lastTalkedAt.map { calendar.dateComponents([.day], from: $0, to: now).day ?? 0 } ?? 0
        let withinThreeDays = daysSinceLast < 3

        switch (self, stage) {
        // MARK: リン
        case (.lin, 0):
            return "はじめまして！私はリンです。一緒に中国語、頑張りましょう！"
        case (.lin, 1):
            return "あ、\(name)さん来てくれたんだ。今日も練習しよ？"
        case (.lin, 2):
            return withinThreeDays
                ? "\(name)さん、今日も来たんですね。"
                : "久しぶり〜！元気だった？"
        case (.lin, _): // stage 3
            return talkedToday
                ? "また来てくれたの、嬉しい。"
                : "来てくれた。今日も話そうね。"

        // MARK: ウェイ
        case (.wei, 0):
            return "こんにちは。王建です。中国語、一緒に頑張りましょう。"
        case (.wei, 1):
            return "また来たんですね。継続できてるじゃないですか。"
        case (.wei, 2):
            return withinThreeDays
                ? "\(name)、今日も来たんだね。"
                : "久しぶりだね。忙しかった？"
        case (.wei, _): // stage 3
            return talkedToday
                ? "また俺に会いに来たの？…嬉しいけど。"
                : "待ってたよ。今日も話そう。"

        // MARK: メイ
        case (.mei, 0):
            return "こんにちは！陳美麗です。しっかり教えますよ。"
        case (.mei, 1):
            return "来ましたね。今日はどこまでやりましょうか。"
        case (.mei, 2):
            return withinThreeDays
                ? "\(name)さん、今日も来たの。感心ね。"
                : "あら、久しぶりじゃない。サボってたでしょ？"
        case (.mei, _): // stage 3
            return talkedToday
                ? "また来たの。熱心ねえ。でも悪くない。"
                : "来たわね。今日も頑張りましょ。"
        }
    }
}
