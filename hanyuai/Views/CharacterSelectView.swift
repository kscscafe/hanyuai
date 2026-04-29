import SwiftUI

struct CharacterSelectView: View {
    @Binding var selectedCharacter: ChatCharacter?

    var body: some View {
        VStack(spacing: 24) {
            // 小龍の挨拶
            VStack(spacing: 8) {
                Image("ShaoLong")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .background(Color.clear)
                Text("小龍（シャオロン）")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("一緒に中国語を学ぼう！\nまず話す相手を選んでね。")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding(.top, 40)

            // キャラクター選択
            VStack(spacing: 16) {
                ForEach(ChatCharacter.allCases) { character in
                    CharacterCard(character: character) {
                        selectedCharacter = character
                        UserDefaults.standard.set(character.rawValue, forKey: "selectedCharacter")
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationTitle("チューターを選ぶ")
    }
}

struct CharacterCard: View {
    let character: ChatCharacter
    let onTap: () -> Void

    private var avatarScale: CGFloat {
        switch character {
        case .lin: return 1.0
        case .wei: return 1.3
        case .mei: return 1.3
        }
    }

    private var avatarOffsetY: CGFloat {
        switch character {
        case .lin: return 0
        case .wei: return 8
        case .mei: return 8
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // キャラクター顔写真（顔がフレーム中央に来るよう微調整）
                Image(character.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(avatarScale)
                    .offset(y: avatarOffsetY)
                    .frame(width: 90, height: 90)
                    .clipped()
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(character.nameJP)(\(character.displayName))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(character.profile)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}
