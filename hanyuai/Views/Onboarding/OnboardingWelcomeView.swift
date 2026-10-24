import SwiftUI

/// オンボーディング 1/3: HanYuAIでできること。
struct OnboardingWelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingBrand()
                .padding(.top, 28)

            Spacer(minLength: 36)

            Text("HanYuAIでできること")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.white)
                .padding(.bottom, 24)

            VStack(spacing: 14) {
                FeatureRow(
                    icon: "bubble.left.and.bubble.right",
                    title: "AIチューターと会話"
                )
                FeatureRow(
                    icon: "book",
                    title: "単語・例文で発音と声調を確認"
                )
                FeatureRow(
                    icon: "list.bullet",
                    title: "中国語の文を並び替えて練習"
                )
            }

            Spacer()

            Button(action: onNext) {
                Text("次へ")
            }
            .onboardingPrimaryButton()
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingStyle.background.ignoresSafeArea())
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(OnboardingStyle.cyan)
                .frame(width: 42)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(OnboardingStyle.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(OnboardingStyle.cardStroke, lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingWelcomeView(onNext: {})
}
