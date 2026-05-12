import SwiftUI

/// チャット画面のアバター画像をタップしたときに sheet で表示する、
/// キャラクターのプロフィール詳細ビュー。
struct CharacterProfileView: View {
    let character: ChatCharacter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(character.avatarImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding(.top, 16)

                    VStack(spacing: 4) {
                        Text(character.displayName)
                            .font(.title2.bold())
                        Text(character.nameJP)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(character.hometownLabel)
                        .font(.callout)
                        .foregroundColor(.secondary)

                    Text(character.profile)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    Spacer(minLength: 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("閉じる")
                }
            }
        }
    }
}

#Preview {
    CharacterProfileView(character: .lin)
}
