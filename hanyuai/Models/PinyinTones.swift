//
//  PinyinTones.swift
//  hanyuai
//
//  pinyin 文字列の声調記号 (ā á ǎ à など) を読み取り、各音節の声調番号 (0〜4) を返す。
//  スペース区切りでない連結ピンイン (例: "jǐngchá") にも対応。

import Foundation

enum PinyinTones {
    /// 連結ピンインも含めて、含まれる音節すべての声調を順に返す。
    /// 例: "nǐ hǎo" → [3, 3] / "jǐngchá" → [3, 2] / "māma" → [1, 0]
    static func tones(for pinyin: String) -> [Int] {
        var result: [Int] = []
        var currentTone: Int = 0
        var hasVowelInCurrentSyllable = false
        var prevWasVowel = false

        func flushSyllable() {
            if hasVowelInCurrentSyllable {
                result.append(currentTone)
            }
            currentTone = 0
            hasVowelInCurrentSyllable = false
        }

        for ch in pinyin {
            if ch.isWhitespace || isHardSeparator(ch) {
                flushSyllable()
                prevWasVowel = false
                continue
            }

            if let toneValue = toneMap[ch] {
                // 声調記号付き母音
                // 直前が子音で、すでに母音を含む音節がある場合は新音節
                if !prevWasVowel && hasVowelInCurrentSyllable {
                    flushSyllable()
                }
                currentTone = toneValue
                hasVowelInCurrentSyllable = true
                prevWasVowel = true
            } else if isPlainVowel(ch) {
                if !prevWasVowel && hasVowelInCurrentSyllable {
                    flushSyllable()
                }
                hasVowelInCurrentSyllable = true
                prevWasVowel = true
            } else {
                // 子音
                prevWasVowel = false
            }
        }
        flushSyllable()
        return result
    }

    /// 単一音節（既に区切り済み）の声調を返すヘルパー。
    static func tone(for syllable: String) -> Int {
        for ch in syllable {
            if let value = toneMap[ch] { return value }
        }
        return 0
    }

    // MARK: - private

    private static func isHardSeparator(_ ch: Character) -> Bool {
        ch == "·" || ch == "-" || ch == "'" || ch == "’"
    }

    private static func isPlainVowel(_ ch: Character) -> Bool {
        let lower = Character(ch.lowercased())
        return "aeiouü".contains(lower)
    }

    private static let toneMap: [Character: Int] = [
        // 1声 (macron)
        "ā": 1, "ē": 1, "ī": 1, "ō": 1, "ū": 1, "ǖ": 1,
        "Ā": 1, "Ē": 1, "Ī": 1, "Ō": 1, "Ū": 1, "Ǖ": 1,
        // 2声 (acute)
        "á": 2, "é": 2, "í": 2, "ó": 2, "ú": 2, "ǘ": 2,
        "Á": 2, "É": 2, "Í": 2, "Ó": 2, "Ú": 2, "Ǘ": 2,
        // 3声 (caron)
        "ǎ": 3, "ě": 3, "ǐ": 3, "ǒ": 3, "ǔ": 3, "ǚ": 3,
        "Ǎ": 3, "Ě": 3, "Ǐ": 3, "Ǒ": 3, "Ǔ": 3, "Ǚ": 3,
        // 4声 (grave)
        "à": 4, "è": 4, "ì": 4, "ò": 4, "ù": 4, "ǜ": 4,
        "À": 4, "È": 4, "Ì": 4, "Ò": 4, "Ù": 4, "Ǜ": 4,
    ]
}
