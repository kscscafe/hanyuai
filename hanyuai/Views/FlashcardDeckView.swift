//
//  FlashcardDeckView.swift
//  hanyuai
//
//  単語デッキを横スワイプで切り替えながら学習する画面。

import SwiftUI

struct FlashcardDeckView: View {
    let words: [Word]
    var title: String = "フラッシュカード"
    var deckID: String? = nil

    @State private var index = 0
    @State private var shuffled: [Word] = []
    @State private var didRestore = false

    var body: some View {
        let deck = shuffled.isEmpty ? words : shuffled

        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 12) {
                progressBar(current: index, total: deck.count)
                    .padding(.horizontal)

                TabView(selection: $index) {
                    ForEach(Array(deck.enumerated()), id: \.element.id) { i, word in
                        FlashcardView(word: word)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                controls(deckCount: deck.count)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { restartFromBeginning() } label: {
                        Label("最初から始める", systemImage: "backward.end.fill")
                    }
                    Button { shuffleDeck() } label: {
                        Label("シャッフル", systemImage: "shuffle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear { restoreIfNeeded() }
        .onChange(of: index) { _, newValue in
            persistIfPossible(newValue)
        }
    }

    // MARK: - 進捗バー

    private func progressBar(current: Int, total: Int) -> some View {
        let progress = total == 0 ? 0 : Double(current + 1) / Double(total)
        return VStack(spacing: 6) {
            HStack {
                Text("\(current + 1) / \(total)")
                    .font(.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                if hasResumePoint {
                    Text("前回の続きから")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.tertiaryText)
                }
            }
            ProgressView(value: progress)
                .tint(AppTheme.accent)
        }
    }

    // MARK: - 前後ボタン

    private func controls(deckCount: Int) -> some View {
        HStack(spacing: 8) {
            navButton(
                title: "前へ",
                icon: "chevron.left",
                disabled: index == 0
            ) {
                if index > 0 { withAnimation { index -= 1 } }
            }

            navButton(
                title: "+10",
                icon: "forward.fill",
                disabled: index >= deckCount - 1
            ) {
                let target = min(index + 10, max(deckCount - 1, 0))
                if target != index { withAnimation { index = target } }
            }

            navButton(
                title: "次へ",
                icon: "chevron.right",
                disabled: index >= deckCount - 1
            ) {
                if index < deckCount - 1 { withAnimation { index += 1 } }
            }
        }
    }

    private func navButton(
        title: String,
        icon: String,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.callout.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                )
                .foregroundStyle(disabled ? AppTheme.tertiaryText : AppTheme.primaryText)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    // MARK: - 状態操作

    private func shuffleDeck() {
        shuffled = words.shuffled()
        index = 0
    }

    private func restartFromBeginning() {
        shuffled = []
        index = 0
        if let deckID {
            StudyProgressStore.reset(for: deckID)
        }
    }

    // MARK: - 進捗保存・復元

    private var hasResumePoint: Bool {
        guard let deckID, !didRestore else { return false }
        return StudyProgressStore.index(for: deckID) > 0
    }

    private func restoreIfNeeded() {
        guard !didRestore, let deckID else {
            didRestore = true
            return
        }
        let saved = StudyProgressStore.index(for: deckID)
        if saved > 0 && saved < words.count {
            index = saved
        }
        didRestore = true
    }

    private func persistIfPossible(_ newIndex: Int) {
        guard didRestore, shuffled.isEmpty, let deckID else { return }
        StudyProgressStore.setIndex(newIndex, for: deckID)
    }
}

#Preview {
    NavigationStack {
        FlashcardDeckView(words: WordRepository.hsk1, deckID: "preview")
    }
    .environmentObject(FavoritesStore())
    .preferredColorScheme(.dark)
}
