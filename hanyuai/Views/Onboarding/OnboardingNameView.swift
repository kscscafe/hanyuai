import SwiftUI

/// オンボーディング 2/3: 名前入力ページ。
struct OnboardingNameView: View {
    let onNext: () -> Void

    @ObservedObject private var profile = UserProfile.shared
    @State private var draftName: String = UserProfile.shared.name
    @FocusState private var isFocused: Bool

    private var trimmedName: String {
        draftName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingBrand()
                .padding(.top, 28)

            Spacer(minLength: 48)

            Text("なんて呼べばいい？")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.white)

            Text("AIチューターが、この名前で呼びかけます")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
                .padding(.top, 10)
                .padding(.bottom, 34)

            TextField("あなたの名前", text: $draftName)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(OnboardingStyle.cardFill)
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(OnboardingStyle.cyan, lineWidth: 1.5)
                )
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(saveAndProceed)

            Spacer()

            Button(action: saveAndProceed) {
                Text("次へ")
            }
            .onboardingPrimaryButton()
            .padding(.bottom, 60)
            .opacity(trimmedName.isEmpty ? 0.4 : 1.0)
            .disabled(trimmedName.isEmpty)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingStyle.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }

    private func saveAndProceed() {
        guard !trimmedName.isEmpty else { return }
        profile.name = trimmedName
        isFocused = false
        onNext()
    }
}

#Preview {
    OnboardingNameView(onNext: {})
}
