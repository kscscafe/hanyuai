//
//  ExampleSentenceView.swift
//  hanyuai
//
//  例文 (exampleChinese) を seicho の声調列に基づいて文字背景色付きで表示する。
//  AttributedString を用いるため自然に折り返される。

import SwiftUI

struct ExampleSentenceView: View {
    let word: Word
    var fontSize: CGFloat = 18
    var weight: Font.Weight = .regular
    /// 白パネル上に置く場合 true（文字色を黒、1声色を黒に切替）
    var onLightBackground: Bool = false

    var body: some View {
        Text(attributed)
            .font(.system(size: fontSize, weight: weight))
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributed: AttributedString {
        var result = AttributedString()
        let textColor: Color = onLightBackground ? .black : .white
        for pair in word.exampleCharactersWithTones {
            var piece = AttributedString(String(pair.character))
            piece.foregroundColor = textColor
            let bg = onLightBackground
                ? pair.tone?.backgroundColorOnLight
                : pair.tone?.backgroundColor
            if let bg {
                piece.backgroundColor = bg.opacity(0.30)
            }
            result += piece
        }
        return result
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ExampleSentenceView(word: .preview)
        if let first = WordRepository.hsk1.first {
            ExampleSentenceView(word: first)
        }
    }
    .padding()
}
