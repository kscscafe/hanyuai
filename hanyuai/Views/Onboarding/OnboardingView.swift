import SwiftUI

/// 初回起動時に表示する3ページのオンボーディング。
/// PageTabViewStyle で横スワイプ可能。最終ページの「はじめる」で
/// `UserProfile.shared.isOnboardingCompleted = true` にすることで、
/// `ContentView` 側がホーム画面に切り替わる。
struct OnboardingView: View {
    @ObservedObject private var profile = UserProfile.shared
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingWelcomeView(onNext: { withAnimation { currentPage = 1 } })
                    .tag(0)
                OnboardingNameView(onNext: { withAnimation { currentPage = 2 } })
                    .tag(1)
                OnboardingCharacterView(onStart: completeOnboarding)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        profile.isOnboardingCompleted = true
    }
}

#Preview {
    OnboardingView()
}
