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
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 12) {
                Text("なんて呼べばいい？")
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.primaryText)
                Text("チャット中にこの名前で呼びかけます")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            TextField("あなたの名前", text: $draftName)
                .textFieldStyle(.plain)
                .padding(14)
                .background(AppTheme.cardBackground)
                .foregroundStyle(AppTheme.primaryText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.cardStroke, lineWidth: 0.5)
                )
                .padding(.horizontal, 32)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(saveAndProceed)

            Spacer()

            Button(action: saveAndProceed) {
                Text("次へ")
            }
            .primaryButtonBackground()
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
            .opacity(trimmedName.isEmpty ? 0.4 : 1.0)
            .disabled(trimmedName.isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
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
