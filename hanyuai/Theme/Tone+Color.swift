//
//  Tone+Color.swift
//  hanyuai
//
//  声調色分けルール:
//    1声: 白(暗背景)/黒(明背景) / 2声: 黄 / 3声: 青 / 4声: 赤 / 軽声: 色なし

import SwiftUI

extension Tone {
    /// 暗いカード背景に乗せるときの色。
    var backgroundColor: Color? {
        switch self {
        case .first:   return Color.white
        case .second:  return .yellow
        case .third:   return Color(red: 0.40, green: 0.65, blue: 1.0)
        case .fourth:  return Color(red: 1.0, green: 0.40, blue: 0.45)
        case .neutral: return nil
        }
    }

    /// 白い面に乗せるときの背景色。1声・軽声は背景なし（黒文字色のみで表現）。
    var backgroundColorOnLight: Color? {
        switch self {
        case .first:   return nil
        case .second:  return Color(red: 0.95, green: 0.75, blue: 0.10)
        case .third:   return Color(red: 0.20, green: 0.50, blue: 0.95)
        case .fourth:  return Color(red: 0.90, green: 0.25, blue: 0.30)
        case .neutral: return nil
        }
    }
}
