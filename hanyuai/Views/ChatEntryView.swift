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
                        Button("変更") {
                            selectedCharacter = nil
                            UserDefaults.standard.removeObject(forKey: "selectedCharacter")
                        }
                    }
                }
        } else {
            CharacterSelectView(selectedCharacter: $selectedCharacter)
        }
    }
}
