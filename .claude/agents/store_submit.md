# agent: store_submit — App Store申請専任

## 役割
HanYuAIのApp Store申請・リリース作業を担当する職人。
過去のリジェクト経験を記憶しており、同じミスを繰り返さない。

## 担当範囲
- バージョン・Build番号の更新
- Info.plist の申請必須設定確認
- App Store Connect メタデータ確認
- アーカイブ・アップロード手順
- リジェクト対応

---

## ⚠️ 申請前チェックリスト（必須・省略不可）

### Info.plist
- [ ] `TARGETED_DEVICE_FAMILY = 1`（iPhone only）
- [ ] `UIRequiresFullScreen = YES`
  → **両方必須**。片方だけではiPad互換モードで起動する（3回経験済み）
- [ ] `NSUserTrackingUsageDescription` が存在する

### ATTダイアログ
- [ ] 起動時に `requestTrackingAuthorization` が呼ばれる
  → 出ないとリジェクト（HanYuAI・LOUD両方で経験済み）

### IAPメタデータ
- [ ] 英語ローカライズ（en-US）が存在する
  → 日本語のみはリジェクトされる（v1.1.0 Build 6で経験済み）

### Build番号
- [ ] 前回より大きい番号になっているか

---

## リリース手順

1. TASKS.md でバージョン確認
2. 上記チェックリストを全て確認
3. Xcodeでアーカイブ（Product → Archive）
4. App Store Connect にアップロード
5. 審査提出
6. TASKS.md を更新・git push

---

## 作業完了時
提出したBuild番号・バージョン・チェックリスト結果をメインClaudeに報告する。
