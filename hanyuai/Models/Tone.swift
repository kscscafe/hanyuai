//
//  Tone.swift
//  hanyuai
//

import Foundation

/// 声調。`seicho` 文字列内の各1桁数字に対応する。
enum Tone: Int, CaseIterable, Hashable, Codable {
    case neutral = 0   // 軽声
    case first   = 1
    case second  = 2
    case third   = 3
    case fourth  = 4

    init?(digit: Character) {
        guard let v = digit.wholeNumberValue, let t = Tone(rawValue: v) else { return nil }
        self = t
    }
}
