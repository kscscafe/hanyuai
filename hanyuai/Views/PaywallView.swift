import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreKitManager
    @EnvironmentObject var session: ChatSession
    @Environment(\.dismiss) var dismiss

    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    var premiumProduct: Product? {
        storeManager.products.first { $0.id == IAPProduct.premiumMonthly }
    }

    var ticketProduct: Product? {
        storeManager.products.first { $0.id == IAPProduct.ticket10 }
    }

    var body: some View {
        VStack(spacing: 24) {
            // キャラクター画像（既存アセット名 "ShaoLong" に合わせる）
            Image("ShaoLong")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text("プレミアムプラン")
                .font(.title.bold())

            // 特典一覧
            VStack(alignment: .leading, spacing: 12) {
                Label("チャット無制限", systemImage: "message.fill")
                Label("広告非表示", systemImage: "speaker.slash.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.15))
            .cornerRadius(12)

            // プレミアム購入ボタン
            Button {
                Task { await purchasePremium() }
            } label: {
                if isPurchasing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text(premiumProduct?.displayPrice != nil
                         ? "月額\(premiumProduct!.displayPrice)で始める"
                         : "月額600円で始める")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(14)
            .disabled(isPurchasing)

            // チケット購入ボタン
            Button {
                Task { await purchaseTicket() }
            } label: {
                Text(ticketProduct?.displayPrice != nil
                     ? "チケット10回分 \(ticketProduct!.displayPrice)"
                     : "チケット10回分 ¥120")
                    .foregroundColor(.purple)
            }
            .disabled(isPurchasing)

            // リストア
            Button("購入を復元") {
                Task { await storeManager.restorePurchases() }
            }
            .font(.caption)
            .foregroundColor(.gray)

            Button("閉じる") { dismiss() }
                .foregroundColor(.gray)

            // サブスクリプション開示（Apple 3.1.2 必須）
            VStack(alignment: .leading, spacing: 6) {
                Text("HanYuAI プレミアム（月額自動更新）")
                    .font(.caption.bold())
                Text("• 期間終了の24時間以上前に解除しない限り自動更新されます\n• 更新料金は期間終了の24時間以内に App Store アカウントに課金されます\n• 解約は App Store の登録設定からいつでも可能です")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    Link("利用規約", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Link("プライバシーポリシー", destination: URL(string: "https://officees.co.jp/hanyuai/privacy")!)
                }
                .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
        .padding()
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "購入に失敗しました")
        }
    }

    func purchasePremium() async {
        guard let product = premiumProduct else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let success = try await storeManager.purchase(product)
            if success { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func purchaseTicket() async {
        guard let product = ticketProduct else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let success = try await storeManager.purchase(product)
            if success {
                session.addBonusTurns(10)
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
