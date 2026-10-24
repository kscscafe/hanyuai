//
//  HomeView.swift
//  hanyuai
//
//  HSKレベル選択 + レベル診断テストへの導線。

import SwiftUI

private struct HomeDashboardView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var session: ChatSession
    @ObservedObject private var profile = UserProfile.shared
    @State private var showProfileSettings = false
    @State private var showChatGuide = false

    var body: some View {
        NavigationStack {
            ZStack {
                homeBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            homeHeader
                            aiTutorSection

                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeading("単語カード", icon: "book")
                                levelGrid
                            }

                            sentencePracticeSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                    .scrollContentBackground(.hidden)

                    // 非プレミアム時のみ AdMob バナーを表示
                    if !session.isPremium {
                        BannerAdView(adUnitID: AdUnitID.banner)
                            .frame(height: 50)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showProfileSettings) {
                ProfileSettingsView()
            }
            .navigationDestination(isPresented: $showChatGuide) {
                ChatGuideView()
            }
        }
    }

    // MARK: - 背景・ヘッダー

    private var homeBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.015, green: 0.070, blue: 0.120),
                Color(red: 0.010, green: 0.105, blue: 0.175),
                Color(red: 0.010, green: 0.055, blue: 0.095),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var homeHeader: some View {
        HStack(spacing: 16) {
            HStack(spacing: 0) {
                Text("HanYu")
                    .foregroundStyle(.white)
                Text("AI")
                    .foregroundStyle(Color(red: 0.10, green: 0.91, blue: 0.85))
            }
            .font(.system(size: 34, weight: .bold, design: .rounded))

            Spacer()

            NavigationLink {
                SavedExpressionsListView()
            } label: {
                Image(systemName: "bookmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("記録した表現")

            Button {
                showProfileSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("設定")
        }
    }

    // MARK: - 例文トレーニング

    private var sentencePracticeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading("並び替え練習", icon: "line.3.horizontal.decrease")

            practiceModeRow(.listening)
            practiceModeRow(.japanese)
        }
    }

    private func practiceModeRow(_ mode: SentenceOrderingMode) -> some View {
        NavigationLink {
            SentenceOrderingView(mode: mode)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: mode == .listening ? "headphones" : "doc.text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(red: 0.35, green: 0.92, blue: 1.0))
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.04, green: 0.45, blue: 0.82),
                                        Color(red: 0.13, green: 0.22, blue: 0.58),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                Text(mode.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.10)))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.025, green: 0.16, blue: 0.27))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.cyan.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionHeading(_ title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2.weight(.medium))
                .foregroundStyle(Color(red: 0.12, green: 0.93, blue: 0.93))
                .frame(width: 32)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText)
        }
    }

    // MARK: - AIチューター

    private var aiTutorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading("会話練習", icon: "bubble.left")

            VStack(alignment: .leading, spacing: 16) {
                chatEntryButton

                Text("日本語で質問して大丈夫。\n知りたい表現を聞いてみよう。")
                    .font(.body)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineSpacing(4)

                Divider()
                    .overlay(Color.white.opacity(0.10))

                chatGuideLink
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(red: 0.020, green: 0.13, blue: 0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.cyan.opacity(0.20), lineWidth: 1)
            )
        }
    }

    // MARK: - プロフィール充実バナー

    private var profilePromptBanner: some View {
        Button {
            showProfileSettings = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white)
                Text("プロフィールを充実させるとチャットが変わります ✨")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.pinkGradient)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - レベル診断カード

    private var diagnosisCard: some View {
        NavigationLink {
            LevelTestView()
        } label: {
            featureRow(
                icon: "checklist",
                gradient: AppTheme.buttonGradient,
                title: "レベル診断テスト",
                subtitle: "10問であなたの目安レベルを判定"
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - お気に入りカード

    private var favoritesCard: some View {
        let count = favorites.favoriteIDs.count
        return NavigationLink {
            FlashcardDeckView(
                words: favorites.favoriteWords(),
                title: "お気に入り",
                deckID: "favorites"
            )
        } label: {
            featureRow(
                icon: "heart.fill",
                gradient: AppTheme.pinkGradient,
                title: "お気に入り",
                subtitle: count == 0 ? "ハートをタップして登録" : "\(count) 単語を復習"
            )
        }
        .buttonStyle(.plain)
        .disabled(count == 0)
        .opacity(count == 0 ? 0.55 : 1.0)
    }

    // MARK: - HSK1〜4

    private var levelGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(HSKLevel.allCases) { level in
                NavigationLink {
                    FlashcardDeckView(
                        words: WordRepository.words(of: level),
                        title: level.label,
                        deckID: level.label
                    )
                } label: {
                    LevelCard(level: level, count: WordRepository.words(of: level).count)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - AIチャット導線

    private var chatEntryButton: some View {
        NavigationLink(destination: ChatEntryView()) {
            HStack(spacing: 14) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)

                Text("AIチューターとチャット")
                    .font(.title3.weight(.bold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.16)))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.00, green: 0.65, blue: 1.00),
                        Color(red: 0.02, green: 0.52, blue: 0.98),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.blue.opacity(0.28), radius: 12, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var chatGuideLink: some View {
        Button {
            showChatGuide = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.10, green: 0.60, blue: 1.0))

                Text("中国語でチャットするには")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(red: 0.48, green: 0.45, blue: 0.92))
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("中国語でチャットするには")
    }

    // MARK: - 共通カード

    private func featureRow(
        icon: String,
        gradient: LinearGradient,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(Circle().fill(gradient))
                .shadow(color: AppTheme.accent.opacity(0.35), radius: 8, y: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

// MARK: - HSKレベルカード

private struct LevelCard: View {
    let level: HSKLevel
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "book.fill")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(iconForeground)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(iconGradient)
                )
                .shadow(color: accentColor.opacity(0.28), radius: 8, y: 3)

            Text(level.label.replacingOccurrences(of: "HSK", with: "HSK "))
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .layoutPriority(1)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white.opacity(0.10)))
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 68)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.025, green: 0.15, blue: 0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(accentColor.opacity(0.22), lineWidth: 1)
        )
    }

    private var iconForeground: Color {
        switch level {
        case .hsk1: return Color(red: 0.40, green: 1.00, blue: 0.80)
        case .hsk2: return Color(red: 0.58, green: 0.85, blue: 1.00)
        case .hsk3: return Color(red: 1.00, green: 0.82, blue: 0.45)
        case .hsk4: return Color(red: 1.00, green: 0.64, blue: 0.70)
        }
    }

    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor.opacity(0.78), accentColor.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var accentColor: Color {
        switch level {
        case .hsk1: return Color(red: 0.05, green: 0.75, blue: 0.52)
        case .hsk2: return Color(red: 0.05, green: 0.45, blue: 0.95)
        case .hsk3: return Color(red: 0.90, green: 0.48, blue: 0.10)
        case .hsk4: return Color(red: 0.90, green: 0.25, blue: 0.35)
        }
    }
}

enum HomeTab: Hashable {
    case home
    case learning
    case chat
    case words
    case ordering
}

struct HomeView: View {
    @State private var selectedTab: HomeTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }
                .tag(HomeTab.home)

            NavigationStack {
                LearningGuideView(selectedTab: $selectedTab)
            }
            .tabItem { Label("学び方", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }
            .tag(HomeTab.learning)

            NavigationStack {
                ChatEntryView()
            }
            .tabItem { Label("チャット", systemImage: "bubble.left") }
            .tag(HomeTab.chat)

            WordDeckTabView()
                .tabItem { Label("単語・例文", systemImage: "book") }
                .tag(HomeTab.words)

            OrderingModeTabView()
                .tabItem { Label("並び替え", systemImage: "checklist") }
                .tag(HomeTab.ordering)
        }
        .tint(Color(red: 0.10, green: 0.91, blue: 0.85))
        .toolbarBackground(Color(red: 0.015, green: 0.055, blue: 0.09), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

private struct WordDeckTabView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var session: ChatSession
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                wordTabBackground
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("単語カード")
                                    .font(.title3.bold())
                                    .foregroundStyle(AppTheme.primaryText)

                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(HSKLevel.allCases) { level in
                                        NavigationLink {
                                            FlashcardDeckView(
                                                words: WordRepository.words(of: level),
                                                title: level.label,
                                                deckID: level.label
                                            )
                                        } label: {
                                            LevelCard(level: level, count: WordRepository.words(of: level).count)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            NavigationLink {
                                LevelTestView()
                            } label: {
                                featureRow(
                                    icon: "checklist",
                                    title: "レベル診断テスト",
                                    subtitle: "10問であなたの目安レベルを判定",
                                    gradient: AppTheme.buttonGradient
                                )
                            }
                            .buttonStyle(.plain)

                            let favoriteCount = favorites.favoriteIDs.count
                            NavigationLink {
                                FlashcardDeckView(
                                    words: favorites.favoriteWords(),
                                    title: "お気に入り",
                                    deckID: "favorites"
                                )
                            } label: {
                                featureRow(
                                    icon: "heart.fill",
                                    title: "お気に入り",
                                    subtitle: favoriteCount == 0 ? "ハートをタップして登録" : "\(favoriteCount) 単語を復習",
                                    gradient: AppTheme.pinkGradient
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(favoriteCount == 0)
                            .opacity(favoriteCount == 0 ? 0.55 : 1.0)
                        }
                        .padding(20)
                    }
                    .scrollContentBackground(.hidden)

                    if !session.isPremium {
                        BannerAdView(adUnitID: AdUnitID.banner)
                            .frame(height: 50)
                    }
                }
            }
            .navigationTitle("単語・例文")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("単語検索")
                }
            }
        }
    }

    private var wordTabBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.015, green: 0.070, blue: 0.120),
                Color(red: 0.010, green: 0.105, blue: 0.175),
                Color(red: 0.010, green: 0.055, blue: 0.095),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func featureRow(
        icon: String,
        title: String,
        subtitle: String,
        gradient: LinearGradient
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(gradient)
                )
                .shadow(color: Color.cyan.opacity(0.18), radius: 8, y: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.025, green: 0.15, blue: 0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.cyan.opacity(0.14), lineWidth: 1)
        )
    }
}

private struct OrderingModeTabView: View {
    @EnvironmentObject private var session: ChatSession

    var body: some View {
        NavigationStack {
            ZStack {
                orderingTabBackground
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 14) {
                        orderingLink(.listening)
                        orderingLink(.japanese)
                        Spacer()
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    if !session.isPremium {
                        BannerAdView(adUnitID: AdUnitID.banner)
                            .frame(height: 50)
                    }
                }
            }
            .navigationTitle("並び替え練習")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var orderingTabBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.015, green: 0.070, blue: 0.120),
                Color(red: 0.010, green: 0.105, blue: 0.175),
                Color(red: 0.010, green: 0.055, blue: 0.095),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func orderingLink(_ mode: SentenceOrderingMode) -> some View {
        NavigationLink {
            SentenceOrderingView(mode: mode)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode == .listening ? "headphones" : "doc.text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(red: 0.35, green: 0.92, blue: 1.0))
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.04, green: 0.45, blue: 0.82),
                                        Color(red: 0.13, green: 0.22, blue: 0.58),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                Text(mode.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.10)))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.025, green: 0.16, blue: 0.27))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.cyan.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(FavoritesStore())
        .environmentObject(ChatSession())
        .environmentObject(StoreKitManager())
        .preferredColorScheme(.dark)
}
