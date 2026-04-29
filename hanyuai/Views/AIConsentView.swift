import SwiftUI

/// AIチャット機能を初めて使う前に表示する同意モーダル。
/// 「同意して使う」を押すと AIConsentManager.shared.isAIConsentGiven が true になり、
/// 以降このモーダルは出なくなる。
struct AIConsentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var consent = AIConsentManager.shared

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(AppTheme.buttonGradient)

                Text("AIチャット機能の利用について")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 12) {
                    Text("AIチャット機能はOpenAI APIを使用します。入力内容はOpenAIのサーバーで処理されます。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .glassCard()

                Spacer()

                Button(action: agree) {
                    Text("同意して使う")
                }
                .primaryButtonBackground()
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 32)
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(true)
    }

    private func agree() {
        consent.isAIConsentGiven = true
        dismiss()
    }
}

#Preview {
    AIConsentView()
}
