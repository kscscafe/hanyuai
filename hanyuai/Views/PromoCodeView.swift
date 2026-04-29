import SwiftUI
import UIKit

struct PromoCodeView: View {
    @ObservedObject var session: ChatSession
    @Environment(\.dismiss) private var dismiss

    @State private var code: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    private let apiURL = URL(string: "https://hanyuai-api.vercel.app/api/validate-code")!

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.purple)
                    .padding(.top, 24)

                Text("プロモコードを入力")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("お持ちのコードを入力すると\nチャット回数が追加されます。")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("コードを入力", text: $code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.characters)
                    .disabled(isLoading)
                    .padding(.horizontal, 8)

                Button(action: applyCode) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.purple.opacity(0.6))
                            .cornerRadius(12)
                    } else {
                        Text("適用")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(code.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.purple)
                            .cornerRadius(12)
                    }
                }
                .disabled(isLoading || code.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding(24)
            .navigationTitle("コード入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") {
                    if alertTitle == "成功" { dismiss() }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - API

    private func applyCode() {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true

        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let body: [String: Any] = [
            "code": trimmed,
            "deviceId": deviceId
        ]

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData

        // --- デバッグ ---
        print("===== PromoCode API Request =====")
        print("URL: \(apiURL.absoluteString)")
        print("Method: \(request.httpMethod ?? "?")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let bodyData, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("Body: \(bodyString)")
        } else {
            print("Body: <encode failed>")
        }
        // --- ここまで ---

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                // --- デバッグ: レスポンス ---
                print("===== PromoCode API Response =====")
                if let http = response as? HTTPURLResponse {
                    print("Status: \(http.statusCode)")
                }
                if let bodyString = String(data: data, encoding: .utf8) {
                    print("Body: \(bodyString)")
                } else {
                    print("Body: <非UTF8 / \(data.count) bytes>")
                }
                // --- ここまで ---

                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let valid = (json?["valid"] as? Bool) ?? false
                let turns = (json?["turns"] as? Int) ?? 0
                let serverMessage = json?["message"] as? String
                print("Parsed: valid=\(valid), turns=\(turns), message=\(serverMessage ?? "<nil>")")

                await MainActor.run {
                    isLoading = false
                    if valid && turns > 0 {
                        session.addBonusTurns(turns)
                        alertTitle = "成功"
                        alertMessage = "\(turns)回分追加されました!"
                    } else {
                        alertTitle = "エラー"
                        alertMessage = serverMessage ?? "無効なコードです"
                    }
                    showAlert = true
                }
            } catch {
                print("===== PromoCode API Error =====")
                print("\(error)")
                await MainActor.run {
                    isLoading = false
                    alertTitle = "エラー"
                    alertMessage = "通信に失敗しました。もう一度試してください。"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    PromoCodeView(session: ChatSession())
}
