import SwiftUI

struct ChatEntryView: View {
    @State private var selectedCharacter: ChatCharacter? = {
        guard let raw = UserDefaults.standard.string(forKey: "selectedCharacter"),
              let char = ChatCharacter(rawValue: raw) else { return nil }
        return char
    }()

    var body: some View {
        if let character = selectedCharacter {
            ChatView(character: character)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            selectedCharacter = nil
                            UserDefaults.standard.removeObject(forKey: "selectedCharacter")
                        } label: {
                            Image(systemName: "person.2.fill")
                        }
                        .accessibilityLabel("キャラクターを変更")
                    }
                }
        } else {
            CharacterSelectView(selectedCharacter: $selectedCharacter)
        }
    }
}
