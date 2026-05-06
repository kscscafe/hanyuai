# HanYuAI 開発注意事項

## 基本情報
- アプリ名：HanYuAI（AIと話して学ぶ中国語）
- Bundle ID：jp.co.officees.hanyuai
- リポジトリ：github.com/kscscafe/hanyuai
- API：github.com/kscscafe/hanyuai-api（Vercel）
- サポートサイト：https://officees.co.jp/hanyuai/
- 現在のバージョン：v1.1.0 Build 7（審査中）

## 技術スタック
- フロント：SwiftUI（iOS・iPhone only・ポートレート固定）
- API：Vercel（Node.js）→ OpenAI GPT-4o-mini
- プロモコード制限：Upstash Redis（hnd1/Tokyo）
- 分析：Firebase Analytics
- 広告：AdMob
- 課金：StoreKit2（IAP）

## システム構成
| コンポーネント | 役割 |
|---|---|
| iOS App (SwiftUI) | メインアプリ |
| Bundle内 HSK4音声 | 1,797件のmp3、実行時外部接続なし |
| TTS (AVSpeechSynthesizer) | HSK1〜3の暫定音声（先生音声に差し替え予定） |
| UserDefaults | ターン数・プロモコード・チャット履歴をローカル保存 |
| Vercel (Node.js) | api/chat.js（OpenAI中継）・api/validate-code.js（プロモコード） |
| OpenAI GPT-4o-mini | チャットAI本体 |
| Upstash Redis | プロモコード1デバイス1回制限（hnd1/Tokyo） |
| Firebase Analytics | イベント記録 |

## キャラクター
| キャラ | 性別 | ペルソナ |
|---|---|---|
| 小龍（シャオロン） | — | マスコット龍、起動挨拶担当 |
| リン（林 小雨） | 女性 | 上海出身・日本留学中の大学院生 |
| ウェイ（王 建） | 男性 | 北京出身・日系企業勤務 |
| メイ（陳 美麗） | 女性 | 広州出身・中国語教師 |

## 課金設計
- 無料：1日3ターン
- チケット：10回分（消耗型IAP）
- プレミアム：月額サブスク（無制限）
- プロモコード：HANYU10（10回）・HANYU30（30回）

---

## ⚠️ チャット系：触るたびに必ず確認

### キャラ別チャット履歴
- v1.1実装予定：キャラごとに最新50件を保持・UserDefaultsで永続化
- 現状（v1.0）：ChatViewのonAppearでclearMessages()を呼ぶ暫定対応

### キャラ切り替え時の履歴汚染（過去バグ）
- ChatSessionが全キャラ共通1インスタンスのため切り替えで汚染される
- 対策済み（v1.0）：onAppearでclearMessages()
- v1.1以降：messagesをキャラIDをキーにした辞書型に変更すること

### 日跨ぎでのターン数フリーズ（過去バグ・対策済み）
- addMessage(role:content:)の先頭でresetIfNewDay()を毎回呼ぶ
- init()だけに日付依存処理を置かない

---

## ⚠️ 声調色分けの仕様

| 声調 | 色 |
|---|---|
| 第1声 | 透明 |
| 第2声 | 黄 |
| 第3声 | 青 |
| 第4声 | 赤 |
| 軽声 | 透明 |

白は使わない（ダークモード対応時に浮く）。

---

## ⚠️ 音声系：ファイル追加・変更時に必ず確認

- ファイル名が1文字でもズレるとエラーなしでTTSにフォールバックする
- Xcodeの「Add to target」チェックを確認
- Clean Build Folder（⇧⌘K）を実施
- 追加後に実機で耳確認（TTSと先生の声は明確に違う）

---

## ⚠️ App Store申請の必須設定（過去リジェクト経験）

- TARGETED_DEVICE_FAMILY = 1（iPhone only）
- UIRequiresFullScreen = YES（Info.plistに明示・必須）
  → 片方だけではiPad互換モードで起動してしまう（3回経験済み）
- NSUserTrackingUsageDescription（Info.plistに必須）
- ATTダイアログが出ないとリジェクトされる（LOUD・HanYuAI両方で経験）

---

## セッション管理ルール
- 作業開始時：docs/sessions/ の直近ファイルを確認してから着手
- 作業終了時：必ず /session_end コマンドを実行
- まとめは docs/sessions/YYYYMMDD.md に保存
- TASKS.md を更新してから git push

## 現在の優先タスク（詳細はTASKS.md参照）
1. 🔴 v1.1.0 審査通過待ち
2. 🟡 HSK4級例文の先生音声差し替え
3. 🟡 Firebase Analytics導入
4. 🟢 聞き流し機能・並び替え問題
