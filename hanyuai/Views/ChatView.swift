import SwiftUI
import UIKit
import FirebaseAnalytics

struct ChatView: View {
    let character: ChatCharacter
    @EnvironmentObject private var session: ChatSession
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var showPaywall = false
    @State private var showPromoCode = false
    @State private var openingLine: String? = nil
    @State private var characterState: CharacterState = CharacterState()
    @State private var showConsent: Bool = false

    private var currentMessages: [ChatMessage] {
        session.messagesByCharacter[character.rawValue] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // ターン数表示 + 関係性インジケーター
            if !session.isPremium {
                HStack(spacing: 12) {
                    Image(systemName: "message")
                    Text("残り\(session.remainingTurns)回")
                        .font(.caption)
                    affinityBadge
                    Spacer()
                    Button("コードを入力") {
                        showPromoCode = true
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                    Button("プレミアムへ") {
                        showPaywall = true
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
            }

            // メッセージ一覧
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // 開幕セリフ（その日すでにチャットしている場合は非表示）
                        if currentMessages.isEmpty, let line = openingLine {
                            GreetingBubble(character: character, text: line)
                        }
                        ForEach(currentMessages) { message in
                            MessageBubble(message: message, character: character)
                                .id(message.id)
                        }
                        if isLoading {
                            TypingIndicator()
                        }
                    }
                    .padding(16)
                }
                .onChange(of: currentMessages.count) { _, _ in
                    if let last = currentMessages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // 入力欄
            HStack(spacing: 12) {
                TextField("メッセージを入力...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!session.canSendMessage)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(inputText.isEmpty || !session.canSendMessage ? .gray : .purple)
                }
                .disabled(inputText.isEmpty || isLoading || !session.canSendMessage)
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .navigationTitle("\(character.nameJP)とチャット")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showPromoCode) {
            PromoCodeView(session: session)
        }
        .sheet(isPresented: $showConsent) {
            AIConsentView()
        }
        .onAppear {
            // キャラ別履歴を使うため、レガシーな共有 messages のみクリアする（per-character 履歴は維持）
            session.clearMessages()
            prepareOpeningLine()
            refreshCharacterState()
            // AI 利用同意を未取得なら、最初に同意モーダルを出す
            if !AIConsentManager.shared.isAIConsentGiven {
                showConsent = true
            }
        }
        .onChange(of: currentMessages.count) { _, _ in
            refreshCharacterState()
        }
    }

    /// ハート + 累計ターン数 + ステージ名のバッジ。テーマカラーに馴染ませた控えめなデザイン。
    private var affinityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundStyle(AppTheme.pinkGradient)
            Text("\(characterState.affinity)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.primary)
            Text(shortStageLabel(for: characterState.stage))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule().fill(Color.primary.opacity(0.06))
        )
    }

    private func shortStageLabel(for stage: Int) -> String {
        switch stage {
        case 0: return "初対面"
        case 1: return "知合い"
        case 2: return "親しい"
        default: return "特別"
        }
    }

    private func refreshCharacterState() {
        characterState = CharacterState.load(for: character.rawValue)
    }

    /// stage と最終会話日時に応じた開幕セリフを用意する。
    /// `openingMessage(...)` 自体が「当日複数回目」「3日以上空き」などのバリエーションを内包しているため、
    /// ChatView を開くたびにその時点に最も合うセリフを生成する。
    private func prepareOpeningLine() {
        let state = CharacterState.load(for: character.rawValue)
        openingLine = character.openingMessage(
            stage: state.stage,
            lastTalkedAt: state.lastTalkedAt,
            userName: UserProfile.shared.name
        )
    }

    private func sendMessage() {
        guard !inputText.isEmpty, session.canSendMessage else { return }

        // キーボード（および Dictation セッション）を閉じて
        // inputText のリセットを確実に UI に反映させる
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )

        let text = inputText
        inputText = ""
        session.addMessage(role: "user", content: text, characterId: character.rawValue)
        Analytics.logEvent("chat_message_sent", parameters: ["character": character.rawValue])
        isLoading = true

        // OpenAI へは直近10件のみ送る（コンテキスト肥大防止）
        let recentMessages = Array(currentMessages.suffix(10))

        // API へ送る時点での関係性スナップショット（このターン分の加算前）
        let stateSnapshot = CharacterState.load(for: character.rawValue)

        Task {
            do {
                let reply = try await AIService.shared.sendMessage(
                    messages: recentMessages,
                    character: character,
                    userProfile: UserProfile.shared,
                    state: stateSnapshot
                )
                await MainActor.run {
                    session.addMessage(role: "assistant", content: reply, characterId: character.rawValue)
                    session.recordTurnCompleted(characterId: character.rawValue)
                    isLoading = false
                    // 音声入力(Dictation)対策: 完了時にも明示的にクリア
                    inputText = ""
                }
            } catch {
                await MainActor.run {
                    session.addMessage(role: "assistant", content: "エラーが発生しました。もう一度試してください。", characterId: character.rawValue)
                    isLoading = false
                    inputText = ""
                }
            }
        }
    }
}

struct GreetingBubble: View {
    let character: ChatCharacter
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(character.avatarImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            Text(text)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .cornerRadius(4, corners: [.topLeft])
            Spacer()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let character: ChatCharacter

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isUser {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.topRight])
            } else {
                Image(character.avatarImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                Text(message.content)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.topLeft])
                Spacer()
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var opacity = 0.3

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.secondary)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: opacity)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            Spacer()
        }
        .onAppear { opacity = 1.0 }
    }
}
