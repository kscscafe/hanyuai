import Foundation
import Combine

/// ユーザーのプロフィール情報。
/// オンボーディングと設定画面から書き換えられ、UserDefaults に永続化される。
final class UserProfile: ObservableObject {
    static let shared = UserProfile()

    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: Keys.name) }
    }
    @Published var hobby: String {
        didSet { UserDefaults.standard.set(hobby, forKey: Keys.hobby) }
    }
    @Published var favoriteFood: String {
        didSet { UserDefaults.standard.set(favoriteFood, forKey: Keys.favoriteFood) }
    }
    @Published var studyPurpose: String {
        didSet { UserDefaults.standard.set(studyPurpose, forKey: Keys.studyPurpose) }
    }
    @Published var isOnboardingCompleted: Bool {
        didSet { UserDefaults.standard.set(isOnboardingCompleted, forKey: Keys.onboardingCompleted) }
    }

    /// 趣味・好きな食べ物・学習目的のいずれも未入力か（バナー表示の判定に使用）
    var hasAnyOptionalProfile: Bool {
        !hobby.isEmpty || !favoriteFood.isEmpty || !studyPurpose.isEmpty
    }

    private init() {
        let d = UserDefaults.standard
        self.name = d.string(forKey: Keys.name) ?? ""
        self.hobby = d.string(forKey: Keys.hobby) ?? ""
        self.favoriteFood = d.string(forKey: Keys.favoriteFood) ?? ""
        self.studyPurpose = d.string(forKey: Keys.studyPurpose) ?? ""
        self.isOnboardingCompleted = d.bool(forKey: Keys.onboardingCompleted)
    }

    private enum Keys {
        static let name = "userProfile.name"
        static let hobby = "userProfile.hobby"
        static let favoriteFood = "userProfile.favoriteFood"
        static let studyPurpose = "userProfile.studyPurpose"
        static let onboardingCompleted = "userProfile.isOnboardingCompleted"
    }
}
