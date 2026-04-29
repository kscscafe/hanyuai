//
//  StudyProgressStore.swift
//  hanyuai
//
//  デッキ単位で「最後に表示していたカードのインデックス」を UserDefaults に保存・復元する。

import Foundation

enum StudyProgressStore {
    private static let keyPrefix = "hanyuai.deckIndex."

    static func index(for deckID: String, in defaults: UserDefaults = .standard) -> Int {
        defaults.integer(forKey: keyPrefix + deckID)
    }

    static func setIndex(_ index: Int, for deckID: String, in defaults: UserDefaults = .standard) {
        defaults.set(index, forKey: keyPrefix + deckID)
    }

    static func reset(for deckID: String, in defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: keyPrefix + deckID)
    }
}
