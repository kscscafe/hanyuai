import SwiftUI

/// プロフィール編集画面（HomeViewの右上⚙️ボタンから sheet で表示）。
/// ドラフトに編集して「保存」を押した時のみ UserProfile.shared に反映する。
struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profile = UserProfile.shared

    @State private var name: String = ""
    @State private var hobby: String = ""
    @State private var favoriteFood: String = ""
    @State private var studyPurpose: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本") {
                    TextField("名前", text: $name)
                }
                Section {
                    TextField("趣味", text: $hobby)
                    TextField("好きな食べ物", text: $favoriteFood)
                    TextField("学習目的", text: $studyPurpose)
                } header: {
                    Text("AIチャット用プロフィール（任意）")
                } footer: {
                    Text("入力した内容はAIチューターが会話で参照します。")
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") { save() }
                        .bold()
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear(perform: loadCurrent)
    }

    private func loadCurrent() {
        name = profile.name
        hobby = profile.hobby
        favoriteFood = profile.favoriteFood
        studyPurpose = profile.studyPurpose
    }

    private func save() {
        profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.hobby = hobby.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.favoriteFood = favoriteFood.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.studyPurpose = studyPurpose.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
    }
}

#Preview {
    ProfileSettingsView()
}
