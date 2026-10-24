import SwiftUI

/// 初回起動時に表示する3ページのオンボーディング。
struct OnboardingView: View {
    @ObservedObject private var profile = UserProfile.shared
    @State private var currentPage = 0
    @State private var selectedCharacter: ChatCharacter = {
        guard let raw = UserDefaults.standard.string(forKey: "selectedCharacter"),
              let character = ChatCharacter(rawValue: raw) else { return .lin }
        return character
    }()

    var body: some View {
        ZStack {
            OnboardingStyle.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingWelcomeView(onNext: { withAnimation { currentPage = 1 } })
                    .tag(0)
                OnboardingNameView(onNext: { withAnimation { currentPage = 2 } })
                    .tag(1)
                OnboardingCharacterView(
                    selectedCharacter: $selectedCharacter,
                    onStart: completeOnboarding
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(selectedCharacter.rawValue, forKey: "selectedCharacter")
        profile.isOnboardingCompleted = true
    }
}

enum OnboardingStyle {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.015, green: 0.070, blue: 0.120),
            Color(red: 0.010, green: 0.105, blue: 0.175),
            Color(red: 0.010, green: 0.055, blue: 0.095)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.87, blue: 0.95),
            Color(red: 0.05, green: 0.55, blue: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cardFill = Color(red: 0.02, green: 0.14, blue: 0.24).opacity(0.82)
    static let cyan = Color(red: 0.08, green: 0.87, blue: 0.95)
    static let cardStroke = Color(red: 0.05, green: 0.55, blue: 1.0).opacity(0.55)
}

struct OnboardingBrand: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("HanYu")
                .foregroundStyle(.white)
            Text("AI")
                .foregroundStyle(OnboardingStyle.cyan)
        }
        .font(.system(size: 31, weight: .bold, design: .rounded))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func onboardingPrimaryButton() -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(OnboardingStyle.buttonGradient)
            )
            .foregroundStyle(.white)
            .shadow(color: OnboardingStyle.cyan.opacity(0.20), radius: 12, y: 4)
    }
}

#Preview {
    OnboardingView()
}
