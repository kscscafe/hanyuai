import SwiftUI

/// オンボーディング 1/3: 「ようこそ」ページ。
struct OnboardingWelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image("ShaoLong")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .shadow(color: AppTheme.accent.opacity(0.4), radius: 16, y: 6)

            VStack(spacing: 12) {
                Text("HanYuAIへようこそ")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.primaryText)
                Text("AIキャラと話しながら中国語を学ぼう")
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: onNext) {
                Text("次へ")
            }
            .primaryButtonBackground()
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
    }
}

#Preview {
    OnboardingWelcomeView(onNext: {})
}
