import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Image("ShaoLong")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text("プレミアムプラン")
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "message.fill", text: "チャット無制限")
                FeatureRow(icon: "speaker.wave.2.fill", text: "広告非表示")
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)

            // IAP購入ボタン(後でStoreKitと接続)
            Button(action: {
                // TODO: StoreKit IAP実装
            }) {
                Text("月額600円で始める")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.purple)
                    .cornerRadius(12)
            }

            Button(action: {
                // TODO: チケット購入IAP実装
            }) {
                Text("チケット10回分 ¥120")
                    .foregroundColor(.purple)
            }

            Button("閉じる") { dismiss() }
                .foregroundColor(.secondary)
        }
        .padding(24)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(text)
        }
    }
}
