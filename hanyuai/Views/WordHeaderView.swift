//
//  WordHeaderView.swift
//  hanyuai
//
//  拼音 / 漢字（声調色付き）/ 意味 をまとめて表示。

import SwiftUI

struct WordHeaderView: View {
    let word: Word
    var showsMeaning: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            Text(word.pinyin)
                .font(.title3)
                .foregroundStyle(.secondary)

            CharactersWithTonesView(word: word)

            if showsMeaning {
                Text(word.meaning)
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview("意味あり") {
    WordHeaderView(word: .preview)
        .padding()
}

#Preview("意味なし（暗記中）") {
    WordHeaderView(word: .preview, showsMeaning: false)
        .padding()
}
