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
    @State private var showCopyToast: Bool = false

    @AppStorage("initialBonusGranted") private var initialBonusGranted: Bool = false
    @AppStorage("promoBannerDismissed") private var promoBannerDismissed: Bool = false

    private var currentMessages: [ChatMessage] {
        session.messagesByCharacter[character.rawValue] ?? []
    }

    private var shouldShowPromoBanner: Bool {
        initialBonusGranted && !promoBannerDismissed
    }

    var body: some View {
        ZStack(alignment: .bottom) {
        VStack(spacing: 0) {
            // ヘッダーバー：プレミアム時は関係性 + 👑バッジ、非プレミアム時は残り回数 + 課金導線
            HStack(spacing: 12) {
                if session.isPremium {
                    affinityBadge
                    Spacer()
                    Text("👑 プレミアム")
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                } else {
                    Image(systemName: "message")
                    Text("残り\(session.remainingTurns)回")
                        .font(.caption)
                    affinityBadge
                    Spacer()
                    // 「コードを入力」はv1.2でも引き続き非表示（App Store Offer Codes 移行予定）
                    // Button("コードを入力") {
                    //     showPromoCode = true
                    // }
                    // .font(.caption)
                    // .foregroundColor(.purple)
                    Button("プレミアムへ") {
                        showPaywall = true
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))

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
                                .onLongPressGesture {
                                    copyMessage(message.content)
                                }
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

            // プロモコード案内バナー（初回ボーナス付与済み かつ 未dismiss のときだけ表示）
            // TODO: v1.2 - IAP本実装後に復活させる
            // Apple審査対応のため一時非表示（プロモコードはApp Store Offer Codesに移行予定）
            // if shouldShowPromoBanner {
            //     promoCodeBanner
            // }

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

            // 非プレミアム時のみ AdMob バナーを表示（画面最下部）
            if !session.isPremium {
                BannerAdView(adUnitID: AdUnitID.banner)
                    .frame(height: 50)
            }
        }
        if showCopyToast {
            Text("コピーしました")
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.bottom, 90)
                .transition(.opacity)
        }
        }
        .navigationTitle(character.nameJP)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: startNewConversation) {
                    Text("新しい会話")
                        .foregroundColor(.purple)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        // 「コードを入力」シートはv1.2でも引き続き非表示（App Store Offer Codes 移行予定）
        // .sheet(isPresented: $showPromoCode) {
        //     PromoCodeView(session: session)
        // }
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

    /// 入力欄の上に表示する、プロモコード入力導線のバナー。
    /// 初回ボーナス付与済み かつ 未dismiss のときだけ表示される（呼び出し側で判定）。
    private var promoCodeBanner: some View {
        HStack(spacing: 8) {
            Button {
                showPromoCode = true
            } label: {
                Text("プロモコードをお持ちの方はここから入力できます 🎁")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button {
                promoBannerDismissed = true
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(6)
            }
            .accessibilityLabel("バナーを閉じる")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.purple.opacity(0.1))
    }

    private func copyMessage(_ content: String) {
        UIPasteboard.general.string = content
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation { showCopyToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopyToast = false }
        }
    }

    private func startNewConversation() {
        let state = CharacterState.load(for: character.rawValue)
        session.clearHistory(for: character.rawValue)
        let opening = getOpeningMessage(
            characterId: character.rawValue,
            affinity: state.affinity,
            lastTalkedAt: state.lastTalkedAt
        )
        session.addMessage(role: "assistant", content: opening, characterId: character.rawValue)
    }

    /// affinity から stage を導出。CharacterState.stage と同じ閾値を使う（10 / 30 / 60）。
    private func affinityStage(_ affinity: Int) -> Int {
        switch affinity {
        case ..<10: return 0
        case 10..<30: return 1
        case 30..<60: return 2
        default: return 3
        }
    }

    /// 「新しい会話を始める」ボタン用の開幕セリフ。
    /// stage と「7日以上空いたか」を組み合わせて選ぶ。GreetingBubble 用の
    /// `ChatCharacter.openingMessage` とは別体系なので注意。
    private func getOpeningMessage(characterId: String, affinity: Int, lastTalkedAt: Date?) -> String {
        let stage = affinityStage(affinity)
        let isLongAbsence: Bool = {
            guard let last = lastTalkedAt else { return false }
            return Date().timeIntervalSince(last) > 60 * 60 * 24 * 7
        }()

        switch characterId {
        case "lin":
            if isLongAbsence {
                switch stage {
                case 1: return "しばらくぶりですね。また来てくれて嬉しいです。"
                case 2: return "久しぶり！元気だった？また話せて嬉しい。"
                case 3: return "ちょっと心配してたよ。また会えてよかった。"
                default: return "はじめまして！林小雨です。日本語も中国語も、一緒に練習しましょう！"
                }
            } else {
                switch stage {
                case 0: return "はじめまして！林小雨です。日本語も中国語も、一緒に練習しましょう！"
                case 1: return "また来てくれたんですね。今日は何を話しましょうか？"
                case 2: return "来てくれた！今日も楽しく話しましょうね。"
                case 3: return "待ってたよ。今日も一緒に練習しようね。"
                default: return "はじめまして！林小雨です。"
                }
            }
        case "wei":
            if isLongAbsence {
                switch stage {
                case 1: return "しばらくでしたね。また話しましょう。"
                case 2: return "久しぶりだね。忙しかった？"
                case 3: return "ずっと待ってたよ。また話せてよかった。"
                default: return "こんにちは。王建です。中国語の練習、一緒に頑張りましょう。"
                }
            } else {
                switch stage {
                case 0: return "こんにちは。王建です。中国語の練習、一緒に頑張りましょう。"
                case 1: return "また来てくれましたね。今日もどんどん話しましょう。"
                case 2: return "来てくれたね。今日も楽しく話そう。"
                case 3: return "来てくれるの、いつも楽しみにしてるよ。"
                default: return "こんにちは。王建です。"
                }
            }
        case "mei":
            if isLongAbsence {
                switch stage {
                case 1: return "しばらくぶりね。また来てくれて良かった。続けることが大切よ。"
                case 2: return "久しぶりね。サボってたでしょ？また一緒に頑張りましょう。"
                case 3: return "少し心配してたのよ。また会えて嬉しいわ。"
                default: return "はじめまして。陳美麗です。しっかり教えますから、安心してついてきてください。"
                }
            } else {
                switch stage {
                case 0: return "はじめまして。陳美麗です。しっかり教えますから、安心してついてきてください。"
                case 1: return "また来ましたね。今日も丁寧に練習しましょう。"
                case 2: return "来てくれましたね。今日はどんな練習をしましょうか。"
                case 3: return "来てくれると嬉しいわ。今日も一緒に頑張りましょう。"
                default: return "はじめまして。陳美麗です。"
                }
            }
        default:
            return "こんにちは！"
        }
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
