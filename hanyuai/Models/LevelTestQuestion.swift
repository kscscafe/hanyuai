//
//  LevelTestQuestion.swift
//  hanyuai
//
//  レベル診断の1問。漢字を見て意味を4択から選ぶ形式。

import Foundation

struct LevelTestQuestion: Identifiable {
    let id: UUID = UUID()
    let target: Word
    let options: [String]      // 4択（その1つが target.meaning）
    let correctIndex: Int
}
