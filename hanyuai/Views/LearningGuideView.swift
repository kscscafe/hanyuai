import SwiftUI
import FirebaseAnalytics

struct LearningGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showProfileSettings = false

    private let ink = Color(red: 0.03, green: 0.10, blue: 0.15)
    private let cyan = Color(red: 0.10, green: 0.91, blue: 0.85)
    private let card = Color(red: 0.035, green: 0.13, blue: 0.19)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.015, green: 0.055, blue: 0.09), ink, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        titleBlock

                        VStack(spacing: 10) {
                            stepLink(
                                number: 1,
                                icon: "speaker.wave.2",
                                title: "単語カードで発音と声調を確認",
                                subtitle: "音を聞いて、自分の口で言ってみる"
                            ) {
                                FlashcardDeckView(
                                    words: WordRepository.words(of: .hsk1),
                                    title: HSKLevel.hsk1.label,
                                    deckID: HSKLevel.hsk1.label
                                )
                            }

                            stepLink(
                                number: 2,
                                icon: "person.wave.2",
                                title: "例文で発音と声調を確かめる",
                                subtitle: "文の中で聞いて、声に出してみる"
                            ) {
                                PronunciationCheckView(
                                    word: WordRepository.words(of: .hsk1).first ?? .preview,
                                    target: .example
                                )
                            }

                            stepLink(
                                number: 3,
                                icon: "square.grid.2x2",
                                title: "語句を並べて文を作る",
                                subtitle: nil
                            ) {
                                SentenceOrderingView(mode: .japanese)
                            }

                            stepLink(
                                number: 4,
                                icon: "bubble.left",
                                title: "自分の言いたいことをAIに聞く",
                                subtitle: "自己紹介や仕事、趣味など、話したい内容を日本語で聞いてみる"
                            ) {
                                ChatEntryView()
                            }

                            stepLink(
                                number: 5,
                                icon: "bookmark",
                                title: "使う表現を保存する",
                                subtitle: nil
                            ) {
                                ChatEntryView()
                            }

                            stepLink(
                                number: 6,
                                icon: "bubble.left.and.bubble.right",
                                title: "覚えた表現をAIチューターとの会話で使う",
                                subtitle: nil,
                                isLast: true
                            ) {
                                ChatEntryView()
                            }
                        }

                        questionExample
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
                }

                VStack(spacing: 10) {
                    NavigationLink {
                        FlashcardDeckView(
                            words: WordRepository.words(of: .hsk1),
                            title: HSKLevel.hsk1.label,
                            deckID: HSKLevel.hsk1.label
                        )
                    } label: {
                        HStack(spacing: 10) {
                            Spacer()
                            Text("学習をはじめる")
                                .font(.headline.bold())
                            Image(systemName: "chevron.right")
                                .font(.headline.bold())
                            Spacer()
                        }
                        .foregroundStyle(ink)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [cyan, Color(red: 0.05, green: 0.78, blue: 0.80)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)

                    bottomNavigation
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 4)
                .background(.ultraThinMaterial.opacity(0.22))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showProfileSettings) {
            ProfileSettingsView()
        }
        .onAppear { Analytics.logEvent("learning_guide_opened", parameters: nil) }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 0) {
                Text("HanYu")
                    .foregroundStyle(.white)
                Text("AI")
                    .foregroundStyle(cyan)
            }
            .font(.system(size: 25, weight: .bold, design: .rounded))

            Spacer()

            Button {
                showProfileSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 0.72, green: 0.88, blue: 0.96))
                    .frame(width: 44, height: 44)
                    .background(card.opacity(0.9), in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 5)
        .padding(.bottom, 4)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("学び方ガイド")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
            Text("自分のことを、中国語で伝えられるように")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color(red: 0.62, green: 0.75, blue: 0.84))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 1)
    }

    private func stepLink<Destination: View>(
        number: Int,
        icon: String,
        title: String,
        subtitle: String?,
        isLast: Bool = false,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(alignment: .top, spacing: 9) {
                VStack(spacing: 0) {
                    Text("\(number)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(ink)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(cyan))

                    if !isLast {
                        Rectangle()
                            .fill(cyan.opacity(0.85))
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: 42)

                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 27, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(cyan)
                        .frame(width: 60, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(red: 0.06, green: 0.18, blue: 0.25))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(red: 0.61, green: 0.76, blue: 0.86))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.62, green: 0.79, blue: 0.90))
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: subtitle == nil ? 84 : 100, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [card.opacity(0.94), Color(red: 0.025, green: 0.085, blue: 0.13)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .stroke(Color(red: 0.18, green: 0.42, blue: 0.51).opacity(0.35), lineWidth: 1)
                )
            }
        }
        .buttonStyle(.plain)
    }

    private var questionExample: some View {
        NavigationLink(destination: ChatEntryView()) {
            VStack(alignment: .leading, spacing: 12) {
                Label("質問例", systemImage: "ellipsis.bubble.fill")
                    .font(.headline)
                    .foregroundStyle(cyan)

                HStack(spacing: 10) {
                    Text("自分の仕事や趣味を、\n中国語でどう紹介する？")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.headline.bold())
                        .foregroundStyle(Color(red: 0.55, green: 0.83, blue: 0.94))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(card.opacity(0.95), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(card.opacity(0.46))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            tabItem("house.fill", title: "ホーム", selected: true) { dismiss() }
            tabLink("bubble.left", title: "会話") { ChatEntryView() }
            tabLink("book", title: "単語") {
                FlashcardDeckView(
                    words: WordRepository.words(of: .hsk1),
                    title: HSKLevel.hsk1.label,
                    deckID: HSKLevel.hsk1.label
                )
            }
            tabLink("checklist", title: "並び替え") {
                SentenceOrderingView(mode: .japanese)
            }
        }
        .padding(.top, 9)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func tabItem(
        _ icon: String,
        title: String,
        selected: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 22, weight: .semibold))
                Text(title).font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(selected ? cyan : Color(red: 0.63, green: 0.73, blue: 0.81))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 3)
        }
        .buttonStyle(.plain)
    }

    private func tabLink<Destination: View>(
        _ icon: String,
        title: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 22, weight: .regular))
                Text(title).font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(Color(red: 0.63, green: 0.73, blue: 0.81))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        LearningGuideView()
    }
    .environmentObject(FavoritesStore())
    .environmentObject(ChatSession())
    .preferredColorScheme(.dark)
}
