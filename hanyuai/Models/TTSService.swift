//
//  TTSService.swift
//  hanyuai
//
//  OpenAI TTS（Vercel 経由）でキャラクターごとの音声を生成・再生するサービス。
//  既存の SpeechSynthesizer (AVSpeechSynthesizer) は HSK1〜3 例文用として温存し、
//  本サービスはチャット返答の読み上げ専用とする。
//
//  動作確認方法:
//  1. ChatView で AI 返答バブル右下の 🔊 ボタンをタップする。
//  2. キャラクター固有の音声 (nova/echo/shimmer) が再生されることを耳確認する。
//  3. 再生中はそのバブルのボタンが青くハイライトされることを目視確認する。
//  4. ProfileSettingsView の「読み上げ範囲」を「中国語のみ」/「全文」で切り替えると
//     抽出範囲が変わることを確認する（中国語のみ：混在文から漢字部分のみ抽出）。
//  5. 別バブルのボタンを連打すると前の再生が止まり、新しい再生に切り替わることを確認する。

import Foundation
import AVFoundation
import SwiftUI
import Combine

@MainActor
final class TTSService: NSObject, ObservableObject {
    static let shared = TTSService()

    @Published private(set) var isPlaying = false
    /// 現在再生中のメッセージID（UUID 文字列）。バブル側のボタンハイライトに使う。
    @Published private(set) var playingMessageId: String? = nil

    private var player: AVAudioPlayer?
    private var currentTask: Task<Void, Never>?

    private override init() {
        super.init()
    }

    /// テキストをキャラクター音声で読み上げる。
    /// - Parameters:
    ///   - messageId: UI 側でハイライト判定に使うメッセージ識別子（ChatMessage.id を文字列化したもの）。
    ///   - text: 元のテキスト（日本語/中国語混在可）
    ///   - character: 声の決定に使うキャラクター（小龍 shaolong は ChatCharacter に
    ///     存在しないため、呼び出し側で自然にスキップされる想定）
    ///   - chineseOnly: true なら中国語文字 (U+4E00–U+9FFF, U+3400–U+4DBF) のみを
    ///     抽出して読み上げる。抽出結果が空ならスキップ。
    func speak(messageId: String, text: String, character: ChatCharacter, chineseOnly: Bool, speed: Double) async {
        let payload = chineseOnly ? extractChinese(from: text) : text
        guard !payload.isEmpty else { return }

        // 既存の再生・進行中リクエストを止めてから新しい再生に切り替える
        cancelCurrent()

        let task: Task<Void, Never> = Task { [weak self] in
            guard let self else { return }
            await self.fetchAndPlay(messageId: messageId, text: payload, character: character, speed: speed)
        }
        currentTask = task
        await task.value
    }

    /// 再生・進行中リクエストを即時停止。
    func stop() {
        cancelCurrent()
    }

    // MARK: - Private

    private func cancelCurrent() {
        currentTask?.cancel()
        currentTask = nil
        player?.stop()
        player = nil
        isPlaying = false
        playingMessageId = nil
    }

    private func fetchAndPlay(messageId: String, text: String, character: ChatCharacter, speed: Double) async {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/tts") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "text": text,
            "character": character.rawValue,
            "speed": speed
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try Task.checkCancellation()

            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                print("⚠️ TTS API status: \(http.statusCode)")
                return
            }

            configurePlaybackSession()
            let audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            self.player = audioPlayer
            let started = audioPlayer.play()
            self.isPlaying = started
            self.playingMessageId = started ? messageId : nil
        } catch is CancellationError {
            // 新しい speak() に置き換えられた
        } catch {
            print("⚠️ TTS playback failed: \(error)")
            isPlaying = false
            playingMessageId = nil
        }
    }

    private func extractChinese(from text: String) -> String {
        let pattern = "[\\u{4E00}-\\u{9FFF}\\u{3400}-\\u{4DBF}]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return "" }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: nsRange)
        let parts: [String] = matches.compactMap { match in
            guard let r = Range(match.range, in: text) else { return nil }
            return String(text[r])
        }
        return parts.joined(separator: " ")
    }

    private func configurePlaybackSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            if session.category != .playback && session.category != .ambient {
                try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            }
            try session.setActive(true, options: [])
        } catch {
            print("⚠️ AVAudioSession (playback) setup failed: \(error)")
        }
    }
}

extension TTSService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            self?.isPlaying = false
            self?.playingMessageId = nil
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor [weak self] in
            self?.isPlaying = false
            self?.playingMessageId = nil
        }
    }
}
