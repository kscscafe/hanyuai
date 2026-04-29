//
//  CharactersWithTonesView.swift
//  hanyuai
//
//  単語の各漢字を、声調に対応する背景色付きで横並び表示する。

import SwiftUI

struct CharactersWithTonesView: View {
    let word: Word
    var fontSize: CGFloat = 56
    var spacing: CGFloat = 6
    /// 白いパネル上に乗せる場合 true（文字色を黒、1声色を黒へ切り替え）
    var onLightBackground: Bool = false

    private struct Item: Identifiable {
        let id: Int
        let character: Character
        let tone: Tone?
    }

    private var items: [Item] {
        word.charactersWithTones.enumerated().map { index, pair in
            Item(id: index, character: pair.character, tone: pair.tone)
        }
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(items) { item in
                Text(String(item.character))
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundStyle(onLightBackground ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(backgroundFill(for: item.tone))
                    )
            }
        }
    }

    private func backgroundFill(for tone: Tone?) -> Color {
        let base = onLightBackground ? tone?.backgroundColorOnLight : tone?.backgroundColor
        return base?.opacity(0.30) ?? .clear
    }
}

private func charactersWithTonesPreviewSamples() -> [Word] {
    let head = Array(WordRepository.hsk1.prefix(4))
    return head.isEmpty ? [.preview] : head
}

#Preview {
    VStack(spacing: 24) {
        ForEach(charactersWithTonesPreviewSamples()) { word in
            CharactersWithTonesView(word: word)
        }
    }
    .padding()
}
