//
//  WordRepository.swift
//  hanyuai
//
//  Resources/Words_HSK*.json を読み込んでメモリに保持する。

import Foundation

enum WordRepository {
    static let hsk1: [Word] = load(name: "Words_HSK1")
    static let hsk2: [Word] = load(name: "Words_HSK2")
    static let hsk3: [Word] = load(name: "Words_HSK3")
    static let hsk4: [Word] = load(name: "Words_HSK4")

    static var all: [Word] { hsk1 + hsk2 + hsk3 + hsk4 }

    static func words(of level: HSKLevel) -> [Word] {
        switch level {
        case .hsk1: return hsk1
        case .hsk2: return hsk2
        case .hsk3: return hsk3
        case .hsk4: return hsk4
        }
    }

    private static func load(name: String) -> [Word] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            print("⚠️ \(name).json がバンドルから見つかりません")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Word].self, from: data)
        } catch {
            print("⚠️ \(name).json のデコード失敗: \(error)")
            return []
        }
    }
}
