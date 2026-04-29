//
//  Word.swift
//  hanyuai
//

import Foundation

struct Word: Identifiable, Hashable, Codable {
    let no: Int
    let word: String
    let pinyin: String
    let meaning: String

    let exampleChinese: String
    let examplePinyin: String
    let exampleMeaning: String

    let wordAudio: String      // 例: "audio/HSK1_w001.mp3"
    let exampleAudio: String   // 例: "audio/HSK1_01.mp3"

    let part: String
    let level: HSKLevel
    let seicho: String         // 例文 (exampleChinese) の各文字に対応する声調列

    /// HSKレベル + 番号で安定したID（UUIDではなく決定的な文字列）
    var id: String { "\(level.label)_\(no)" }

    /// 単語の各文字を、pinyin から抽出した声調と対応付ける。
    /// 例: word="儿子" pinyin="ér zi" → [(儿, .second), (子, .neutral)]
    var charactersWithTones: [(character: Character, tone: Tone?)] {
        let chars = Array(word)
        let tones = PinyinTones.tones(for: pinyin)
        return chars.enumerated().map { index, ch in
            if index < tones.count, let tone = Tone(rawValue: tones[index]) {
                return (ch, tone)
            }
            return (ch, nil)
        }
    }

    /// 例文の各文字を `seicho` の数字列と対応付ける。
    var exampleCharactersWithTones: [(character: Character, tone: Tone?)] {
        let chars = Array(exampleChinese)
        let digits = Array(seicho)
        return chars.enumerated().map { index, ch in
            if index < digits.count, let tone = Tone(digit: digits[index]) {
                return (ch, tone)
            }
            return (ch, nil)
        }
    }
}

// MARK: - Preview / プレースホルダ用

extension Word {
    static let preview = Word(
        no: 1,
        word: "你好",
        pinyin: "nǐ hǎo",
        meaning: "こんにちは",
        exampleChinese: "你好，我叫小明。",
        examplePinyin: "Nǐ hǎo, wǒ jiào Xiǎo míng.",
        exampleMeaning: "こんにちは、私はシャオミンといいます。",
        wordAudio: "audio/HSK1_w000.mp3",
        exampleAudio: "audio/HSK1_00.mp3",
        part: "感",
        level: .hsk1,
        seicho: "33034132"
    )
}
