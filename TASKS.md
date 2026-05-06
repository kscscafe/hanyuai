# TASKS.md — HanYuAI
_最終更新：2026-05-06_

---

## 🔴 優先度高

- [ ] v1.1.0 Build 7 審査通過待ち（2026-05-06再提出）
  - UIRequiresFullScreen追加・IAPメタデータ英語ローカライズ済み

---

## 🟡 優先度中

- [ ] HSK4級例文の先生音声差し替え
- [ ] HSK1〜3級例文の再作成・音声整備（TTS→先生音声）
- [ ] Firebase Analytics導入
- [ ] キャラ別チャット履歴（v1.1）
  - messagesをキャラIDキーの辞書型に変更
  - 「新しい会話を始める」ボタン追加
  - 開幕セリフをstage連動に
- [ ] TestFlight外部テスター配布

---

## 🟢 優先度低（v2.0以降）

- [ ] 聞き流し機能実装
- [ ] 並び替え問題①（日本語訳あり）
- [ ] 並び替え問題②（音声のみ）
- [ ] AI模擬試験（読解）
- [ ] ユーザープロフィール機能強化

---

## ✅ 完了済み

- [x] v1.1.0 Build 6 審査提出 - 2026-05-05
- [x] UIRequiresFullScreen = YES 追加（Build 7再提出）- 2026-05-06
- [x] IAPメタデータ英語ローカライズ追加 - 2026-05-06
- [x] officees.co.jp data.js にHanYuAIエントリ追加 - 2026-05-05
- [x] officees.co.jp index.html にプロダクトカード追加 - 2026-05-05
- [x] サポートサイト改善（officees.co.jp/hanyuai/）- 2026-05-05
- [x] app-ads.txt 設置（officees.co.jp）- 2026-05-05
- [x] App Store審査通過・v1.0.0公開 - 2026-05-05
- [x] GitHub リリース v1.0.0 作成 - 2026-05-05
- [x] NSUserTrackingUsageDescription 追加 - 2026-05-05
- [x] StoreKit2 IAP実装（PaywallView・StoreKitManager）- 2026-05-05
- [x] Firebase Analytics導入（v1.1.0）- 2026-05-05
- [x] AIチャット関係性システム（affinity・stage）- 2026-04-29
- [x] オンボーディング追加 - 2026-04-29
- [x] プロモコード1デバイス1回制限（Upstash Redis）- 2026-04-29
- [x] App Store申請完了（Build 3）- 2026-04-29
- [x] AIチャット機能フルスタック実装 - 2026-04-29
- [x] HanYuAI新規開発・フラッシュカード・声調色分け - 2026-04-28

---

## 備考
- Vercel APIエンドポイント：https://hanyuai-api.vercel.app
- Upstash Redis：upstash-kv-crimson-feather（hnd1/Tokyo）
- プロモコード形式：{HANYU10:{turns:10},HANYU30:{turns:30}}
- キャラクター画像：Gemini生成・透過PNG・Assets.xcassetsに登録済み
- HanYuAI Info.plist：UIRequiresFullScreen = YES 追加済み（2026-05-06）
