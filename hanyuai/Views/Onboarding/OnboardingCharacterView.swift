import SwiftUI

/// オンボーディング 3/3: キャラ紹介ページ。
struct OnboardingCharacterView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("チューターはこの3人")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)
                .padding(.top, 32)

            Text("最初に話す相手はあとから選べます")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(ChatCharacter.allCases) { character in
                        CharacterIntroRow(character: character)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }

            Button(action: onStart) {
                Text("はじめる")
            }
            .primaryButtonBackground()
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
    }
}

private struct CharacterIntroRow: View {
    let character: ChatCharacter

    private var origin: String {
        switch character {
        case .lin: return "上海出身"
        case .wei: return "北京出身"
        case .mei: return "広州出身"
        }
    }

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
                .frame(width: 64, height: 64)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("\(character.nameJP)（\(character.displayName)）")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Text(origin)
                    .font(.caption)
                    .foregroundStyle(AppTheme.tertiaryText)
                Text(oneLiner)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

#Preview {
    OnboardingCharacterView(onStart: {})
}
