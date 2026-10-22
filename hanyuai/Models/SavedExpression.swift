import Foundation
import Combine

struct SavedExpression: Identifiable, Codable {
    var id: UUID
    var characterID: String
    var createdAt: Date
    var conversation: String
    var chineseText: String
    var memo: String

    init(
        id: UUID = UUID(),
        characterID: String,
        createdAt: Date = Date(),
        conversation: String,
        chineseText: String,
        memo: String = ""
    ) {
        self.id = id
        self.characterID = characterID
        self.createdAt = createdAt
        self.conversation = conversation
        self.chineseText = chineseText
        self.memo = memo
    }

    var characterName: String {
        ChatCharacter(rawValue: characterID)?.nameJP ?? "AIチューター"
    }

    var preview: String {
        let text = conversation
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { !$0.isEmpty } ?? ""
        return text.isEmpty ? "表現を編集" : text
    }
}

@MainActor
final class SavedExpressionsStore: ObservableObject {
    static let shared = SavedExpressionsStore()
    private let storageKey = "saved_expressions_v1"

    @Published private(set) var expressions: [SavedExpression] = []

    private init() {
        load()
    }

    func add(_ expression: SavedExpression) {
        expressions.insert(expression, at: 0)
        persist()
    }

    func update(_ expression: SavedExpression) {
        guard let index = expressions.firstIndex(where: { $0.id == expression.id }) else { return }
        expressions[index] = expression
        persist()
    }

    func delete(_ expression: SavedExpression) {
        expressions.removeAll { $0.id == expression.id }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SavedExpression].self, from: data) else {
            expressions = []
            return
        }
        expressions = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(expressions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
