//
//  PronunciationCheckView.swift
//  hanyuai
//
//  単語の発音を録音→音声認識→判定する画面。

import SwiftUI

struct PronunciationCheckView: View {
    enum Target {
        case word
        case example
    }

    let word: Word
    var target: Target = .word

    @StateObject private var recognizer = SpeechRecognizer()
    @State private var lastResult: PronunciationJudge.Result?

    private var targetText: String {
        switch target {
        case .word:    return word.word
        case .example: return word.exampleChinese
        }
    }

    private var navigationTitle: String {
        switch target {
        case .word:    return "発音チェック"
        case .example: return "例文の発音練習"
        }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    targetDisplay
                        .padding(.top, 8)

                    transcriptArea
                    resultArea
                    recordButton
                    retryButton
                    hint
                }
                .padding(20)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    SpeechSynthesizer.shared.speak(targetText)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.white)
                }
            }
        }
        .onDisappear {
            Task { await recognizer.stop() }
        }
        .onChange(of: recognizer.isRecording) { _, newValue in
            if !newValue && !recognizer.transcript.isEmpty {
                lastResult = PronunciationJudge.evaluate(
                    expected: targetText,
                    heard: recognizer.transcript
                )
            }
        }
    }

    @ViewBuilder
    private var targetDisplay: some View {
        switch target {
        case .word:
            VStack(spacing: 12) {
                Text(word.pinyin)
                    .font(.title3)
                    .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                CharactersWithTonesView(word: word, fontSize: 56, onLightBackground: true)
                Text(word.meaning)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.lightSurfaceText)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.lightSurface)
            )
        case .example:
            VStack(alignment: .leading, spacing: 10) {
                ExampleSentenceView(word: word, fontSize: 22, weight: .semibold, onLightBackground: true)
                Text(word.examplePinyin)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                Text(word.exampleMeaning)
                    .font(.body)
                    .foregroundStyle(AppTheme.lightSurfaceText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.lightSurface)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(AppTheme.accent)
                    .frame(width: 4)
                    .padding(.vertical, 8)
            }
        }
    }

    private var transcriptArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("聞き取り結果")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Text(displayedTranscript)
                .font(.title3)
                .foregroundStyle(AppTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                )
        }
    }

    private var displayedTranscript: String {
        if recognizer.isRecording && recognizer.transcript.isEmpty {
            return "聞き取り中..."
        }
        if recognizer.transcript.isEmpty {
            return "（まだ録音されていません）"
        }
        return recognizer.transcript
    }

    @ViewBuilder
    private var resultArea: some View {
        if let result = lastResult {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: result.verdict.symbol)
                        .font(.system(size: 28))
                        .foregroundStyle(verdictColor(result.verdict))
                    Text(result.verdict.label)
                        .font(.title2.bold())
                        .foregroundStyle(verdictColor(result.verdict))
                    Spacer()
                    Text("\(Int(result.score * 100))%")
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(AppTheme.secondaryText)
                }
                ProgressView(value: result.score)
                    .tint(verdictColor(result.verdict))
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("正解:").foregroundStyle(AppTheme.secondaryText)
                        Text(result.expected).foregroundStyle(AppTheme.primaryText)
                    }
                    HStack {
                        Text("認識:").foregroundStyle(AppTheme.secondaryText)
                        Text(result.heard).foregroundStyle(AppTheme.primaryText)
                    }
                }
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(verdictColor(result.verdict).opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(verdictColor(result.verdict).opacity(0.4), lineWidth: 0.5)
            )
        } else if let error = recognizer.errorMessage {
            Text(error)
                .font(.callout)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var recordButton: some View {
        Button {
            Task {
                if recognizer.isRecording {
                    await recognizer.stop()
                } else {
                    lastResult = nil
                    await recognizer.start()
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: recognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 28))
                Text(recognizer.isRecording ? "停止して判定" : "録音を開始")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        recognizer.isRecording
                            ? AnyShapeStyle(Color(red: 0.95, green: 0.30, blue: 0.45))
                            : AnyShapeStyle(AppTheme.buttonGradient)
                    )
            )
            .foregroundStyle(.white)
            .shadow(
                color: (recognizer.isRecording ? Color.red : AppTheme.accent).opacity(0.4),
                radius: 12, y: 4
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var retryButton: some View {
        if lastResult == nil
            && (recognizer.isRecording || !recognizer.transcript.isEmpty) {
            Button {
                resetForRetry()
            } label: {
                Label("やり直し", systemImage: "arrow.counterclockwise")
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.20), lineWidth: 0.5)
                    )
                    .foregroundStyle(AppTheme.primaryText)
            }
            .buttonStyle(.plain)
        }
    }

    private func resetForRetry() {
        lastResult = nil
        recognizer.reset()
        Task { await recognizer.stop() }
    }

    private var hint: some View {
        Text("はっきり発音してから「停止して判定」を押してください。")
            .font(.footnote)
            .foregroundStyle(AppTheme.tertiaryText)
            .multilineTextAlignment(.center)
    }

    private func verdictColor(_ verdict: PronunciationVerdict) -> Color {
        switch verdict {
        case .excellent: return Color(red: 0.55, green: 0.95, blue: 0.65)
        case .good:      return Color(red: 0.40, green: 0.70, blue: 1.0)
        case .fair:      return Color(red: 1.0, green: 0.70, blue: 0.40)
        case .poor:      return Color(red: 1.0, green: 0.45, blue: 0.50)
        }
    }
}

#Preview {
    NavigationStack {
        PronunciationCheckView(word: .preview)
    }
    .preferredColorScheme(.dark)
}
