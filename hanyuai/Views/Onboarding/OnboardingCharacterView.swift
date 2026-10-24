import SwiftUI

/// オンボーディング 3/3: AIチューター選択ページ。
struct OnboardingCharacterView: View {
    @Binding var selectedCharacter: ChatCharacter
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingBrand()
                .padding(.top, 28)

            Spacer(minLength: 28)

            Text("AIチューターを選ぶ")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(.white)

            Text("話す相手は、あとから変更できます")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))
                .padding(.top, 8)
                .padding(.bottom, 22)

            VStack(spacing: 12) {
                ForEach(ChatCharacter.allCases) { character in
                    Button {
                        selectedCharacter = character
                    } label: {
                        CharacterIntroRow(
                            character: character,
                            isSelected: selectedCharacter == character
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            Button(action: onStart) {
                Text("はじめる")
            }
            .onboardingPrimaryButton()
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingStyle.background.ignoresSafeArea())
    }
}

private struct CharacterIntroRow: View {
    let character: ChatCharacter
    let isSelected: Bool

    private var oneLiner: String {
        switch character {
        case .lin: return "明るくフレンドリーな大学院生"
        case .wei: return "落ち着いた社会人。気さくで優しい"
        case .mei: return "丁寧に教えてくれる中国語教師"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(character.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 58, height: 58)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("\(character.nameJP)（\(character.displayName)）")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(oneLiner)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isSelected ? OnboardingStyle.cyan : .white.opacity(0.35))
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(OnboardingStyle.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    isSelected ? OnboardingStyle.cyan : OnboardingStyle.cardStroke,
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}

#Preview {
    OnboardingCharacterView(
        selectedCharacter: .constant(.lin),
        onStart: {}
    )
}
