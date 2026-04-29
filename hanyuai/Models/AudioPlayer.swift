//
//  AudioPlayer.swift
//  hanyuai
//
//  Bundle 内の音声ファイル（mp3 等）を AVAudioPlayer で再生する薄いラッパー。

import AVFoundation

@MainActor
final class AudioPlayer {
    static let shared = AudioPlayer()

    private var player: AVAudioPlayer?

    private init() {}

    /// 例: bundlePath = "audio/HSK1_w001.mp3"
    /// 再生に成功したら true。Bundle に該当ファイルがなければ false（フォールバック用途）。
    @discardableResult
    func play(bundlePath: String) -> Bool {
        // --- デバッグ ---
        print("再生試行: \(bundlePath)")
        if let url = Bundle.main.resourceURL {
            print("resourceURL: \(url.path)")
            let audioDir = url.appendingPathComponent("audio")
            let files = try? FileManager.default.contentsOfDirectory(atPath: audioDir.path)
            print("audioフォルダ内ファイル数: \(files?.count ?? 0)")
        }
        // --- ここまで ---

        guard let url = bundleURL(for: bundlePath) else {
            print("⚠️ 音声ファイルが見つかりません: \(bundlePath)")
            return false
        }
        do {
            try configurePlaybackSession()
            print("  [play] sessionOK, url=\(url.lastPathComponent)")
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 1.0
            print("  [play] AVAudioPlayer created, duration=\(player?.duration ?? -1), volume=\(player?.volume ?? -1)")
            player?.prepareToPlay()
            let started = player?.play() ?? false
            print("  [play] play() returned: \(started)")
            return started
        } catch {
            print("⚠️ 音声再生失敗: \(error)")
            return false
        }
    }

    func stop() {
        player?.stop()
    }

    // MARK: - private

    private func configurePlaybackSession() throws {
        let session = AVAudioSession.sharedInstance()
        if session.category != .playback && session.category != .ambient {
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
        }
        try session.setActive(true, options: [])
    }

    /// "audio/HSK1_w001.mp3" を Bundle 内で解決する。
    /// fileSystemSynchronizedGroups は階層をフラット化することがあるため、
    /// サブディレクトリ指定 → ファイル名のみ の順でフォールバック検索する。
    private func bundleURL(for path: String) -> URL? {
        var parts = path.split(separator: "/").map(String.init)
        guard !parts.isEmpty else { return nil }
        let filename = parts.removeLast()
        let nsName = (filename as NSString).deletingPathExtension
        let ext = (filename as NSString).pathExtension
        let subdir = parts.joined(separator: "/")

        print("  [bundleURL] name=\(nsName), ext=\(ext), subdir='\(subdir)'")

        if !subdir.isEmpty {
            if let url = Bundle.main.url(forResource: nsName, withExtension: ext, subdirectory: subdir) {
                print("  [bundleURL] HIT (subdirectory): \(url.path)")
                return url
            } else {
                print("  [bundleURL] miss (subdirectory)")
            }
        }
        if let url = Bundle.main.url(forResource: nsName, withExtension: ext) {
            print("  [bundleURL] HIT (flat): \(url.path)")
            return url
        }
        print("  [bundleURL] miss (flat)")
        return nil
    }
}
