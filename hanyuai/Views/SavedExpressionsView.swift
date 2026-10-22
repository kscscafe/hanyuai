import SwiftUI
import FirebaseAnalytics

struct SavedExpressionsListView: View {
    @StateObject private var store = SavedExpressionsStore.shared

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            if store.expressions.isEmpty {
                ContentUnavailableView(
                    "記録した表現はありません",
                    systemImage: "bookmark",
                    description: Text("AIチューターの中国語の返答を長押しすると、ここに記録できます。")
                )
                .foregroundStyle(AppTheme.primaryText)
            } else {
                List {
                    ForEach(store.expressions) { expression in
                        NavigationLink {
                            SavedExpressionDetailView(expression: expression)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(expression.chineseText.isEmpty ? expression.preview : expression.chineseText)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.primaryText)
                                    .lineLimit(2)
                                Text(expression.preview)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .lineLimit(2)
                                Text("\(expression.characterName)・\(expression.createdAt.formatted(date: .numeric, time: .omitted))")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.tertiaryText)
                            }
                            .padding(.vertical, 5)
                            .listRowBackground(AppTheme.cardBackground)
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { store.expressions[$0] }.forEach(store.delete)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .navigationTitle("記録した表現")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { Analytics.logEvent("saved_expressions_opened", parameters: nil) }
    }
}

struct SavedExpressionDetailView: View {
    @State private var expression: SavedExpression
    @ObservedObject private var store = SavedExpressionsStore.shared
    @ObservedObject private var tts = TTSService.shared
    @Environment(\.dismiss) private var dismiss

    init(expression: SavedExpression) {
        _expression = State(initialValue: expression)
    }

    private var isPlaying: Bool {
        tts.isPlaying && tts.playingMessageId == expression.id.uuidString
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle("会話の記録")
                    TextEditor(text: $expression.conversation)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(minHeight: 150)
                        .padding(10)
                        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 14))

                    HStack {
                        sectionTitle("音声で確認する中国語")
                        Spacer()
                        Button(action: playChinese) {
                            Label(isPlaying ? "再生中" : "再生", systemImage: isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .font(.subheadline.weight(.semibold))
                        }
                        .disabled(expression.chineseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    TextField("中国語の部分を入力", text: $expression.chineseText, axis: .vertical)
                        .lineLimit(2...5)
                        .font(.title3)
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(14)
                        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 14))
                    Text("会話の記録から音声にしたい中国語だけを残せます。")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)

                    sectionTitle("自分のメモ")
                    TextEditor(text: $expression.memo)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(minHeight: 100)
                        .padding(10)
                        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 14))

                    NavigationLink(destination: ChatEntryView()) {
                        Label("AIチューターとの会話で使う", systemImage: "bubble.left.and.bubble.right")
                            .primaryButtonBackground()
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .navigationTitle("表現の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    store.update(expression)
                    dismiss()
                }
                .foregroundStyle(AppTheme.primaryText)
            }
        }
        .onDisappear { store.update(expression) }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppTheme.primaryText)
    }

    private func playChinese() {
        guard let character = ChatCharacter(rawValue: expression.characterID) else { return }
        let storedSpeed = UserDefaults.standard.double(forKey: "tts_speed")
        let speed = storedSpeed == 0 ? 1.0 : storedSpeed
        Task {
            await tts.speak(
                messageId: expression.id.uuidString,
                text: expression.chineseText,
                character: character,
                chineseOnly: false,
                speed: speed
            )
        }
    }
}

#Preview {
    NavigationStack {
        SavedExpressionsListView()
    }
    .preferredColorScheme(.dark)
}
