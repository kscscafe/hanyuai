import SwiftUI
import StoreKit
import UIKit
import FirebaseFirestore

/// レーティングゲート。累計10メッセージ到達時に ChatSession.showRatingGate 経由で表示される。
///
/// 導線:
///   「HanYuAIを楽しんでいますか？」
///     ├ はい  → SKStoreReviewController.requestReview() を呼んでシートを閉じる
///     └ いいえ → フィードバック入力へ遷移
///                 送信 → Firestore "feedback" コレクションに保存
///                       → chatSession.addBonusTurns(10) してシートを閉じる
struct RatingGateView: View {
    @EnvironmentObject private var chatSession: ChatSession
    @Environment(\.dismiss) private var dismiss

    /// 表示ステップ。質問 → フィードバック入力。
    private enum Step {
        case ask
        case feedback
    }

    @State private var step: Step = .ask
    @State private var feedbackText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .ask:
                    askView
                case .feedback:
                    feedbackView
                }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .disabled(isSubmitting)
                }
            }
            .alert("送信に失敗しました", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text("通信に失敗しました。もう一度お試しください。")
            }
        }
    }

    // MARK: - はい / いいえ の質問

    private var askView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.pinkGradient)

            Text("HanYuAIを楽しんでいますか？")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button(action: handleYes) {
                    Text("はい")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.purple)
                        .cornerRadius(12)
                }

                Button(action: { step = .feedback }) {
                    Text("いいえ")
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - フィードバック入力

    private var feedbackView: some View {
        VStack(spacing: 20) {
            Text("ご意見をお聞かせください")
                .font(.title3)
                .fontWeight(.bold)

            Text("いただいたご意見は今後の改善に役立てます。\n送信するとチャット10回分を進呈します。")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextEditor(text: $feedbackText)
                .frame(minHeight: 140)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .disabled(isSubmitting)

            Button(action: submitFeedback) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.purple.opacity(0.6))
                        .cornerRadius(12)
                } else {
                    Text("送信")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.purple)
                        .cornerRadius(12)
                }
            }
            .disabled(isSubmitting || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Spacer()
        }
    }

    // MARK: - Actions

    /// 「はい」: ストアレビューのリクエストを出してシートを閉じる。
    private func handleYes() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        dismiss()
    }

    /// フィードバックを Firestore "feedback" コレクションに保存し、
    /// 完了後にボーナス10回を付与してシートを閉じる。
    private func submitFeedback() {
        let message = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        isSubmitting = true

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

        let db = Firestore.firestore()
        db.collection("feedback").addDocument(data: [
            "message": message,
            "createdAt": Timestamp(date: Date()),
            "appVersion": appVersion
        ]) { error in
            DispatchQueue.main.async {
                isSubmitting = false
                if error != nil {
                    showError = true
                    return
                }
                chatSession.addBonusTurns(10)
                dismiss()
            }
        }
    }
}

#Preview {
    RatingGateView()
        .environmentObject(ChatSession())
}
