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

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            aiTutorSection

                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeading("単語カード")
                                levelGrid
                            }

                            sentencePracticeSection
                            diagnosisCard
                            favoritesCard

                            if !profile.hasAnyOptionalProfile {
                                profilePromptBanner
                            }
                        }
                        .padding(20)
                    }
                    .scrollContentBackground(.hidden)

                    // 非プレミアム時のみ AdMob バナーを表示
                    if !session.isPremium {
                        BannerAdView(adUnitID: AdUnitID.banner)
                            .frame(height: 50)
                    }
                }
            }
            .navigationTitle("HanYuAI")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfileSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showProfileSettings) {
                ProfileSettingsView()
            }
        }
    }

    // MARK: - 例文トレーニング

    private var sentencePracticeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("並び替え練習")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText)
                Text("中国語の文を、聞いて・読んで並び替える")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            practiceModeRow(.listening, subtitle: "音声を聞いて語句を並べる")
            practiceModeRow(.japanese, subtitle: "日本語訳から語句を並べる")
        }
        .padding(16)
        .glassCard()
    }

    private func practiceModeRow(
        _ mode: SentenceOrderingMode,
        subtitle: String
    ) -> some View {
        NavigationLink {
            SentenceOrderingView(mode: mode)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(AppTheme.buttonGradient))

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.tertiaryText)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.elevatedBackground)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(AppTheme.primaryText)
    }

    // MARK: - AIチューター

    private var aiTutorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeading("会話練習")
            chatEntryButton
            chatGuideLink
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
            HStack {
                Image("ShaoLong")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .background(Color.clear)
                Text("AIチューターとチャット")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    /// チャットボタン直下の小さな説明リンク（中国語キーボードの追加方法など）
    private var chatGuideLink: some View {
        NavigationLink(destination: ChatGuideView()) {
            HStack(spacing: 4) {
                Text("中国語でチャットするには")
                Image(systemName: "chevron.right")
                    .font(.caption2)
            }
            .font(.footnote)
            .foregroundStyle(AppTheme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 4)
            .frame(minHeight: 32)
        }
        .buttonStyle(.plain)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(level.label)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)
            Text("\(count) 単語")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer(minLength: 8)
            HStack {
                Spacer()
                Image(systemName: "rectangle.stack.fill")
                    .font(.title2)
                    .foregroundStyle(accentColor)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .topLeading)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(accentColor.opacity(0.40), lineWidth: 1)
        )
    }

    private var accentColor: Color {
        switch level {
        case .hsk1: return Color(red: 0.55, green: 0.85, blue: 0.65)
        case .hsk2: return Color(red: 0.40, green: 0.65, blue: 1.0)
        case .hsk3: return Color(red: 1.0, green: 0.65, blue: 0.30)
        case .hsk4: return Color(red: 1.0, green: 0.40, blue: 0.45)
        }
    }
}


struct HomeView: View {
    var body: some View {
        TabView {
            HomeDashboardView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }

            NavigationStack {
                ChatEntryView()
            }
            .tabItem { Label("会話", systemImage: "bubble.left") }

            WordDeckTabView()
                .tabItem { Label("単語・例文", systemImage: "book") }

            OrderingModeTabView()
                .tabItem { Label("並び替え", systemImage: "checklist") }

            NavigationStack {
                LearningGuideView()
            }
            .tabItem { Label("学び方", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }
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
                AppTheme.background.ignoresSafeArea()
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
            .navigationTitle("単語カード")
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

private struct OrderingModeTabView: View {
    @EnvironmentObject private var session: ChatSession

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("中国語の文を、聞いて・読んで並び替える")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.bottom, 4)

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
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func orderingLink(_ mode: SentenceOrderingMode) -> some View {
        NavigationLink {
            SentenceOrderingView(mode: mode)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(AppTheme.buttonGradient))
                Text(mode.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.tertiaryText)
            }
            .padding(14)
            .glassCard()
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
