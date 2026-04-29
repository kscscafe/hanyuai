import Foundation
import Combine

class ChatSession: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var turnsUsed: Int = 0
    @Published var bonusTurns: Int = 0
    @Published var isPremium: Bool = false

    private let freeTurnsPerDay = 3
    private let lastResetKey = "chatLastResetDate"
    private let turnsUsedKey = "chatTurnsUsed"
    private let bonusTurnsKey = "chatBonusTurns"

    var remainingFreeTurns: Int {
        max(0, freeTurnsPerDay - turnsUsed)
    }

    /// フリーターン + ボーナスチケットの合計残り回数
    var remainingTurns: Int {
        remainingFreeTurns + bonusTurns
    }

    var canSendMessage: Bool {
        isPremium || remainingFreeTurns > 0 || bonusTurns > 0
    }

    init() {
        loadTurns()
        loadBonusTurns()
        resetIfNewDay()
    }

    func addMessage(role: String, content: String) {
        let message = ChatMessage(role: role, content: content)
        messages.append(message)
        if role == "user" {
            // bonusTurns があれば先に消費し、フリーターンを温存する
            if bonusTurns > 0 {
                bonusTurns -= 1
                saveBonusTurns()
            } else {
                turnsUsed += 1
                saveTurns()
            }
        }
    }

    func clearMessages() {
        messages = []
    }

    /// 1往復の会話が成立した時（AI返答受信後）に呼ぶ。
    /// 該当キャラの affinity を 1 加算し、lastTalkedAt を現在時刻にして永続化する。
    func recordTurnCompleted(characterId: String) {
        var state = CharacterState.load(for: characterId)
        state.affinity += 1
        state.lastTalkedAt = Date()
        CharacterState.save(state, for: characterId)
    }

    /// プロモコード適用などで追加チケットを付与する
    func addBonusTurns(_ amount: Int) {
        bonusTurns += amount
        saveBonusTurns()
    }

    // MARK: - Persistence

    private func saveTurns() {
        UserDefaults.standard.set(turnsUsed, forKey: turnsUsedKey)
    }

    private func loadTurns() {
        turnsUsed = UserDefaults.standard.integer(forKey: turnsUsedKey)
    }

    private func saveBonusTurns() {
        UserDefaults.standard.set(bonusTurns, forKey: bonusTurnsKey)
    }

    private func loadBonusTurns() {
        bonusTurns = UserDefaults.standard.integer(forKey: bonusTurnsKey)
    }

    private func resetIfNewDay() {
        let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastReset) {
            turnsUsed = 0
            saveTurns()
            UserDefaults.standard.set(Date(), forKey: lastResetKey)
        }
    }
}
