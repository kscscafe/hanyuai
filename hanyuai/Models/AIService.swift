import Foundation

class AIService {
    static let shared = AIService()
    private let apiURL = "https://hanyuai-api.vercel.app/api/chat"

    func sendMessage(
        messages: [ChatMessage],
        character: ChatCharacter,
        userProfile: UserProfile,
        state: CharacterState
    ) async throws -> String {
        var apiMessages: [[String: String]] = [
            ["role": "system", "content": character.systemPrompt]
        ]
        for msg in messages {
            apiMessages.append(["role": msg.role, "content": msg.content])
        }

        // JSONSerialization は Optional を受け付けないので、nil の場合は NSNull に置換する
        let lastTalkedAt: Any = state.lastTalkedAt
            .map { $0.timeIntervalSince1970 as Any } ?? NSNull()

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": apiMessages,
            "max_tokens": 300,
            "userProfile": [
                "name": userProfile.name,
                "hobby": userProfile.hobby,
                "favoriteFood": userProfile.favoriteFood,
                "studyPurpose": userProfile.studyPurpose
            ],
            "characterState": [
                "affinity": state.affinity,
                "stage": state.stage,
                "lastTalkedAt": lastTalkedAt
            ]
        ]

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        return message?["content"] as? String ?? "返答を取得できませんでした。"
    }
}
