# TASKS.md — HanYuAI
_最終更新：2026-05-07_

---

## 🔴 優先度高

- [ ] v1.1.0 Build 9 審査通過待ち（2026-05-07再々提出）
  - Build 8 リジェクト原因：Guideline 3.1.2(c) - EULAリンク不足
  - Build 9 で App Store説明文にEULA/プライバシーリンク追加・PaywallViewにサブスク開示ブロック追加で対応
  - ticket10 が独立して「審査待ち」キューにいる状態（取消不可）。レビュアーメモで同時審査を依頼
- [ ] v1.2 UX改修（v1.1.0 承認後着手）
  - キャラ × 課金分離設計（farewell message / 0回時UI / Paywall 2枚カード化）
  - swift_dev 指示文は確定済み

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

- [x] v1.1.0 Build 9 アップロード・再々提出（EULA対応）- 2026-05-07
- [x] PaywallView にサブスク開示ブロック追加（タイトル/期間/自動更新条件/EULA/プライバシーリンク）- 2026-05-07
- [x] App Store 説明文に EULA/プライバシーリンク・サブスク情報追加 - 2026-05-07
- [x] v1.1.0 Build 8 アップロード・再提出 - 2026-05-07
- [x] サブスクリプショングループのローカリゼーション追加（メタデータ不足解消）- 2026-05-07
- [x] `.storekit` に `_storefront: "JPN"` を明示追加（シミュレーター¥表示）- 2026-05-07
- [x] PaywallView 審査スクショを ¥ 表示で再撮影・差し替え - 2026-05-07
- [x] グローバル `~/.claude/CLAUDE.md` 整備（氏名修正・Rikuto役割正確化・プロジェクト別体制表追加）- 2026-05-07
- [x] v1.2 UX改修案の確定（キャラ × 課金分離方針）- 2026-05-07
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

## Apple審査の罠（再発防止メモ）
- IAPの「メタデータ不足」は親のサブスクリプショングループのローカリゼーションも確認
- バイナリをアップロードするまで「アプリ内購入とサブスクリプション」セクションは出現しない
- 消耗型IAPの「審査へ提出」は単独で押さない（取消不能・審査待ちに飛ぶ）
- IAP選択ダイアログは「送信準備完了」状態のIAPしか表示しない
- StoreKit設定変更後は Clean Build Folder（⇧⌘K）必須
- Guideline 3.1.2(c)：サブスクアプリは**説明文とPaywallの両方に**EULA/プライバシーポリシーリンクが必要
- Apple標準EULAなら `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/` を貼るだけでOK
- Paywallには「タイトル・期間・価格・自動更新条件・EULA/プライバシーリンク」の5点セットが必須
