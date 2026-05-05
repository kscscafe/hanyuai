import Foundation
import Combine
import StoreKit
import UIKit

class ChatSession: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messagesByCharacter: [String: [ChatMessage]] = [:]
    @Published var turnsUsed: Int = 0
    @Published var bonusTurns: Int = 0
    /// プレミアム判定。実体は StoreKitManager.isPremium で、bindStoreManager(_:) で同期される。
    @Published var isPremium: Bool = false
    /// 累計の user メッセージ送信回数。日跨ぎでもリセットされない。レビュー誘導等の判定に使う。
    @Published var totalMessagesSent: Int = 0
    private var isStoreManagerBound: Bool = false

    let targetCharacters = ["lin", "wei", "mei"]
    private let maxHistoryPerCharacter = 50

    private let freeTurnsPerDay = 3
    private let initialBonus = 7
    private let lastResetKey = "chatLastResetDate"
    private let turnsUsedKey = "chatTurnsUsed"
    private let bonusTurnsKey = "chatBonusTurns"
    private let initialBonusGrantedKey = "initialBonusGranted"
    private let totalMessagesSentKey = "totalMessagesSent"
    private let reviewRequestedKey = "reviewRequested"

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
        totalMessagesSent = UserDefaults.standard.integer(forKey: totalMessagesSentKey)
        if !UserDefaults.standard.bool(forKey: initialBonusGrantedKey) {
            bonusTurns += initialBonus
            saveBonusTurns()
            UserDefaults.standard.set(true, forKey: initialBonusGrantedKey)
        }
        loadAllHistories()
        resetIfNewDay()
    }

    /// user ロールの送信時に呼ぶ。累計カウンタを進めて、しきい値に達した一度だけレビュー誘導を出す。
    private func recordUserMessageSent() {
        totalMessagesSent += 1
        UserDefaults.standard.set(totalMessagesSent, forKey: totalMessagesSentKey)

        if totalMessagesSent == 10 && !UserDefaults.standard.bool(forKey: reviewRequestedKey) {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            UserDefaults.standard.set(true, forKey: reviewRequestedKey)
        }
    }

    private func loadAllHistories() {
        for id in targetCharacters {
            let key = "chat_history_\(id)"
            if let data = UserDefaults.standard.data(forKey: key),
               let history = try? JSONDecoder().decode([ChatMessage].self, from: data) {
                messagesByCharacter[id] = history
            } else {
                messagesByCharacter[id] = []
            }
        }
    }

    func addMessage(role: String, content: String) {
        resetIfNewDay()
        let message = ChatMessage(role: role, content: content)
        messages.append(message)
        if role == "user" {
            recordUserMessageSent()
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

    /// キャラ別履歴に追加する。最新50件のみ保持し、UserDefaults に永続化する。
    /// ターン消費（freeTurns / bonusTurns）は既存の addMessage(role:content:) と同じルールで処理する。
    func addMessage(role: String, content: String, characterId: String) {
        resetIfNewDay()
        let message = ChatMessage(role: role, content: content)
        var history = messagesByCharacter[characterId] ?? []
        history.append(message)
        if history.count > maxHistoryPerCharacter {
            history.removeFirst(history.count - maxHistoryPerCharacter)
        }
        messagesByCharacter[characterId] = history
        saveHistory(for: characterId)

        if role == "user" {
            recordUserMessageSent()
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

    func saveHistory(for characterId: String) {
        if let data = try? JSONEncoder().encode(messagesByCharacter[characterId] ?? []) {
            UserDefaults.standard.set(data, forKey: "chat_history_\(characterId)")
        }
    }

    func clearHistory(for characterId: String) {
        messagesByCharacter[characterId] = []
        UserDefaults.standard.removeObject(forKey: "chat_history_\(characterId)")
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

    /// StoreKitManager の isPremium をこのセッションの isPremium にミラーする。
    /// 一度バインドしたら以降の呼び出しは何もしない（多重購読防止）。
    @MainActor
    func bindStoreManager(_ manager: StoreKitManager) {
        guard !isStoreManagerBound else { return }
        isStoreManagerBound = true
        manager.$isPremium.assign(to: &$isPremium)
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
