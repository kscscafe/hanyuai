//
//  FavoritesStore.swift
//  hanyuai
//
//  お気に入り単語を UserDefaults に永続化して保持する。

import Foundation
import Combine

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []

    private let storageKey = "hanyuai.favoriteIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.array(forKey: storageKey) as? [String] {
            favoriteIDs = Set(saved)
        }
    }

    func isFavorite(_ word: Word) -> Bool {
        favoriteIDs.contains(word.id)
    }

    func toggle(_ word: Word) {
        if favoriteIDs.contains(word.id) {
            favoriteIDs.remove(word.id)
        } else {
            favoriteIDs.insert(word.id)
        }
        defaults.set(Array(favoriteIDs), forKey: storageKey)
    }

    /// 全単語のうちお気に入りに含まれるものをレベル順・no順で返す
    func favoriteWords() -> [Word] {
        WordRepository.all
            .filter { favoriteIDs.contains($0.id) }
            .sorted { lhs, rhs in
                if lhs.level.rawValue != rhs.level.rawValue {
                    return lhs.level.rawValue < rhs.level.rawValue
                }
                return lhs.no < rhs.no
            }
    }
}
