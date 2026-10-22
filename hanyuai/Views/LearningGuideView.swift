import SwiftUI
import FirebaseAnalytics

struct LearningGuideView: View {
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    intro
                    step(number: 1, icon: "rectangle.stack", title: "単語カードで発音と声調を確かめる",
                         body: "音声を聞いたら、自分の口でも言ってみましょう。声調を意識しながら、単語の音を身につけます。",
                         action: "単語カードを見る") {
                        FlashcardDeckView(
                            words: WordRepository.words(of: .hsk1),
                            title: HSKLevel.hsk1.label,
                            deckID: HSKLevel.hsk1.label
                        )
                    }
                    step(number: 2, icon: "waveform", title: "例文の発音と声調を確認する",
                         body: "例文の音声を聞き、文の中で使われる発音や声調を確かめてから、自分で声に出します。")
                    step(number: 3, icon: "textformat.abc", title: "語句を並べて文を作る",
                         body: "中国語の語順を考えながら語句を並べます。単語を知っている状態から、文を組み立てられる状態へ進みます。",
                         action: "並び替え練習を始める") {
                        SentenceOrderingView(mode: .japanese)
                    }
                    step(number: 4, icon: "character.bubble", title: "自分のことを中国語で表現する",
                         body: "自己紹介や仕事、趣味など、自分が実際に話したい内容を日本語でチューターに質問してみましょう。",
                         action: "AIチューターと話す") {
                        ChatEntryView()
                    }
                    step(number: 5, icon: "bookmark", title: "使いたい表現を記録する",
                         body: "チューターの返答を長押しして、あとで使いたい表現を保存します。記録した文章は編集できます。")
                    step(number: 6, icon: "bubble.left.and.bubble.right", title: "覚えた表現を会話で使う",
                         body: "記録した中国語を見返して声に出し、AIチューターとの会話でも使ってみましょう。",
                         action: "AIチューターと話す") {
                        ChatEntryView()
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("学び方ガイド")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { Analytics.logEvent("learning_guide_opened", parameters: nil) }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("単語から、自分の中国語へ")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)
            Text("発音を確かめ、文を作り、自分が使いたい表現を身につけていきます。")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassCard()
    }

    private func step<Destination: View>(
        number: Int,
        icon: String,
        title: String,
        body: String,
        action: String? = nil,
        @ViewBuilder destination: () -> Destination = { EmptyView() }
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("\(number)")
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
                    .frame(width: 27, height: 27)
                    .background(Circle().fill(AppTheme.accent))
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.accent)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            Text(body)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            if let action {
                NavigationLink(destination: destination()) {
                    HStack {
                        Text(action)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryText)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.elevatedBackground)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

#Preview {
    NavigationStack {
        LearningGuideView()
    }
    .preferredColorScheme(.dark)
}
