import Foundation
import Combine

/// OpenAI API 利用に関するユーザーの同意状態を管理する。
/// 同意は端末単位で一度だけ取り、UserDefaults に永続化する。
final class AIConsentManager: ObservableObject {
    static let shared = AIConsentManager()

    @Published var isAIConsentGiven: Bool {
        didSet { UserDefaults.standard.set(isAIConsentGiven, forKey: Keys.consent) }
    }

    private init() {
        self.isAIConsentGiven = UserDefaults.standard.bool(forKey: Keys.consent)
    }

    private enum Keys {
        static let consent = "aiConsent.isAIConsentGiven"
    }
}
