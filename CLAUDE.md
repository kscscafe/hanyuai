# HanYuAI 開発注意事項

## 基本情報
- アプリ名：HanYuAI（AIと話して学ぶ中国語）
- Bundle ID：jp.co.officees.hanyuai
- リポジトリ：github.com/kscscafe/hanyuai
- API：github.com/kscscafe/hanyuai-api（Vercel）
- サポートサイト：https://officees.co.jp/hanyuai/
- 現在のバージョン：v1.2.0 Build 10（審査通過・公開済み、GitHub リリース登録済み）

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
| AVSpeechSynthesizer (SpeechSynthesizer.swift) | HSK1〜3例文の暫定音声（先生音声に差し替え予定） |
| OpenAI TTS (TTSService.swift) | チャット返答のキャラクター音声。バブル右下のスピーカーボタンから手動再生（v1.2〜） |
| UserDefaults | ターン数・プロモコード・チャット履歴・TTS設定をローカル保存 |
| Vercel (Node.js) | api/chat.js（OpenAI中継）・api/validate-code.js（プロモコード）・api/tts.js（OpenAI TTSプロキシ） |
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
- プロモコード：HANYU10（10回）・HANYU30（30回、複数回使用可）／REI50（50回、グローバル1回限り、バックエンド実装済みだがアプリ側入口は v1.3 で再設計予定）

---

## ⚠️ チャット系：触るたびに必ず確認

### キャラ別チャット履歴（v1.1で実装済み）
- ChatSession.messagesByCharacter[characterId] でキャラ別に保持・UserDefaults永続化
- 過去バグ：全キャラ共通1インスタンスで切り替え時に汚染 → 辞書型化で解消済み

### キャラクター情報の集約原則
- キャラの属性（displayName / nameJP / profile / avatarImageName / hometownLabel / systemPrompt / openingMessage）は ChatCharacter.swift に集約する
- View 側でハードコードしない（過去：OnboardingCharacterView に origin が私的に持たれていて重複していた → ChatCharacter.hometownLabel に移管済み）

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
1. 🔴 v1.3 検討：プロモコード入力 UI 復活 or ディープリンク化（REI50 用）
2. 🟡 HSK4級例文の先生音声差し替え
3. 🟢 聞き流し機能・並び替え問題
