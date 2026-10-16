//
//  ChatGuideView.swift
//  hanyuai
//
//  「中国語でチャットするには」の説明画面。
//  簡体中国語キーボードの追加手順と、文字・声での入力方法、最初に言ってみる3フレーズを案内する。

import SwiftUI
import FirebaseAnalytics

struct ChatGuideView: View {
    private let phrases: [(pinyin: String, chinese: String, japanese: String)] = [
        ("nǐ hǎo", "你好！", "こんにちは"),
        ("xièxie", "谢谢！", "ありがとう"),
        ("zàijiàn", "再见！", "さようなら"),
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    header
                    stepCard(number: 1, title: "準備（最初の1回だけ）") {
                        Text("iPhoneに中国語キーボードを追加します。")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                        pathBox("iPhoneの「設定」アプリ → 一般\n→ キーボード → キーボード\n→ 新しいキーボードを追加\n→ 簡体中国語（拼音）")
                    }
                    stepCard(number: 2, title: "キーボードで入力する") {
                        Text("チャット画面の入力欄で、次のどちらかの方法を使います。")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                        pathBox("文字で入力：キーボードの 🌐 で「簡体中国語」に切り替える\n声で入力：キーボードのマイクをタップ →「普通話」を選んで話す")
                    }
                    stepCard(number: 3, title: "まずはこの3つを言ってみよう") {
                        ForEach(phrases, id: \.chinese) { phrase in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(phrase.pinyin)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.tertiaryText)
                                Text(phrase.chinese)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(AppTheme.primaryText)
                                Text(phrase.japanese)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppTheme.background)
                            )
                        }
                    }
                    stepCard(number: 4, title: "わからなければ日本語でOK") {
                        Text("中国語でなんと言えばいいか分からないときは、日本語で聞いてみてください。チューターが、中国語での言い方を教えてくれます。")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        pathBox("例：「ありがとうは中国語でなんて言うの？」")
                    }
                    startButton
                }
                .padding(20)
            }
        }
        .navigationTitle("中国語でチャットするには")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            Analytics.logEvent("chat_guide_opened", parameters: nil)
        }
    }

    // MARK: - Parts

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("ShaoLong")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("小龍（シャオロン）")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                Text("你好！まずは一言、入力してみよう。間違えても大丈夫だよ。")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.cardBackground)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stepCard<Content: View>(
        number: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("\(number)")
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(AppTheme.accent))
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
            }
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private func pathBox(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(AppTheme.primaryText)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.background)
            )
    }

    private var startButton: some View {
        VStack(spacing: 8) {
            NavigationLink(destination: ChatEntryView()) {
                Text("チューターを選んで話す")
                    .primaryButtonBackground()
            }
            Text("無料で1日10回まで話せます")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }
}

#Preview {
    NavigationStack {
        ChatGuideView()
    }
    .preferredColorScheme(.dark)
}
