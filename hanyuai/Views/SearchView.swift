//
//  SearchView.swift
//  hanyuai
//
//  漢字 / 意味 から全単語を横断検索する画面。

import SwiftUI

struct SearchView: View {
    @State private var query: String = ""
    @State private var levelFilter: HSKLevel? = nil

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                levelChips
                List {
                    ForEach(filtered) { word in
                        NavigationLink {
                            ZStack {
                                AppTheme.background.ignoresSafeArea()
                                ScrollView {
                                    FlashcardView(word: word).padding()
                                }
                            }
                            .navigationTitle(word.word)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(.hidden, for: .navigationBar)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                        } label: {
                            SearchRow(word: word)
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                        .listRowSeparatorTint(Color.white.opacity(0.15))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .overlay {
                    if filtered.isEmpty {
                        ContentUnavailableView.search(text: query)
                    }
                }
            }
        }
        .navigationTitle("単語検索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $query, prompt: "漢字 / 意味")
    }

    // MARK: - レベルチップ

    private var levelChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: "全レベル", isSelected: levelFilter == nil) {
                    levelFilter = nil
                }
                ForEach(HSKLevel.allCases) { level in
                    chip(label: level.label, isSelected: levelFilter == level) {
                        levelFilter = (levelFilter == level) ? nil : level
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(
                        isSelected
                            ? AnyShapeStyle(AppTheme.buttonGradient)
                            : AnyShapeStyle(Color.white.opacity(0.10))
                    )
                )
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? Color.clear : Color.white.opacity(0.20),
                        lineWidth: 0.5
                    )
                )
                .foregroundStyle(isSelected ? .white : AppTheme.secondaryText)
        }
        .buttonStyle(.plain)
    }

    // MARK: - フィルタ

    private var filtered: [Word] {
        let pool: [Word]
        if let level = levelFilter {
            pool = WordRepository.words(of: level)
        } else {
            pool = WordRepository.all
        }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return pool }
        return pool.filter { word in
            word.word.contains(trimmed) || word.meaning.contains(trimmed)
        }
    }
}

// MARK: - 行

private struct SearchRow: View {
    let word: Word
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(word.word)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText)
                    Text(word.level.label)
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(AppTheme.accent.opacity(0.4)))
                }
                Text(word.pinyin)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
                Text(word.meaning)
                    .font(.callout)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
            }
            Spacer()
            if favorites.isFavorite(word) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color(red: 1.0, green: 0.40, blue: 0.55))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environmentObject(FavoritesStore())
    .preferredColorScheme(.dark)
}
