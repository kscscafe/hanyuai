import Foundation

/// キャラクターごとの関係性スナップショット。
/// `affinity` は累計会話ターン数で、`stage` はそこから自動算出する。
struct CharacterState: Codable {
    var affinity: Int
    var lastTalkedAt: Date?

    init(affinity: Int = 0, lastTalkedAt: Date? = nil) {
        self.affinity = affinity
        self.lastTalkedAt = lastTalkedAt
    }

    /// affinity から導かれる関係レベル
    /// 0: 初対面 / 1: 知り合い / 2: 親しい / 3: 特別
    var stage: Int {
        switch affinity {
        case ..<10: return 0
        case 10..<30: return 1
        case 30..<60: return 2
        default: return 3
        }
    }

    var stageLabel: String {
        switch stage {
        case 0: return "初対面"
        case 1: return "知り合い"
        case 2: return "親しい"
        default: return "特別な関係"
        }
    }

    // MARK: - Persistence

    private static let keyPrefix = "characterState."

    static func load(for characterId: String) -> CharacterState {
        let key = keyPrefix + characterId
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(CharacterState.self, from: data) else {
            return CharacterState()
        }
        return state
    }

    static func save(_ state: CharacterState, for characterId: String) {
        let key = keyPrefix + characterId
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
