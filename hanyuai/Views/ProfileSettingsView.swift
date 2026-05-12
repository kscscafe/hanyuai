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

    @AppStorage("tts_chinese_only") private var ttsChineseOnly: Bool = true
    @AppStorage("tts_speed") private var ttsSpeed: Double = 1.0

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

                Section {
                    Picker("読み上げ範囲", selection: $ttsChineseOnly) {
                        Text("中国語のみ").tag(true)
                        Text("全文").tag(false)
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("再生速度")
                        Spacer()
                        Text(String(format: "%.1fx", ttsSpeed))
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $ttsSpeed, in: 0.8...1.0)
                } header: {
                    Text("読み上げ")
                } footer: {
                    Text("チャットで AI 返答バブル右下の 🔊 をタップすると、ここで選んだ範囲・速度で読み上げます。「中国語のみ」は混在文から漢字部分だけを抽出します。1.0が標準速度です。")
                }

                Section("データについて") {
                    Text("アプリを削除すると、端末内の学習データはすべて削除されます。サーバーへの保存はありません。")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section("法的情報") {
                    Link(destination: URL(string: "https://kscscafe.github.io/hanyuai-support/privacy.html")!) {
                        externalLinkRow(title: "プライバシーポリシー")
                    }
                    Link(destination: URL(string: "https://kscscafe.github.io/hanyuai-support/terms.html")!) {
                        externalLinkRow(title: "利用規約")
                    }
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

    /// Safari で開く外部リンクの行レイアウト。
    private func externalLinkRow(title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "arrow.up.forward.square")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}

#Preview {
    ProfileSettingsView()
}
