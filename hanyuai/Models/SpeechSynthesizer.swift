//
//  SpeechSynthesizer.swift
//  hanyuai
//
//  AVSpeechSynthesizer の薄いラッパー。中国語(普通話) zh-CN を既定で発音する。

import AVFoundation
import Combine

@MainActor
final class SpeechSynthesizer: ObservableObject {
    static let shared = SpeechSynthesizer()

    @Published private(set) var isSpeaking = false

    // synthesizer はシングルトンと同じライフサイクルで保持される（解放されない）
    private let synthesizer = AVSpeechSynthesizer()
    private let coordinator = Coordinator()

    private init() {
        coordinator.owner = self
        synthesizer.delegate = coordinator
    }

    func speak(_ text: String, language: String = "zh-CN", rate: Float = 0.45) {
        guard !text.isEmpty else { return }

        // 録音セッションが有効だと再生が無音になるので、playback に切り替える
        configurePlaybackSession()

        // 既存の発話があれば必ず停止してから新しい発話を始める
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
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

    fileprivate func updateSpeaking(_ value: Bool) {
        isSpeaking = value
    }
}

private final class Coordinator: NSObject, AVSpeechSynthesizerDelegate {
    weak var owner: SpeechSynthesizer?

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.owner?.updateSpeaking(true)
        }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.owner?.updateSpeaking(false)
        }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.owner?.updateSpeaking(false)
        }
    }
}
