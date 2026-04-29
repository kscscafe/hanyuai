//
//  FlashcardView.swift
//  hanyuai
//
//  1枚のフラッシュカード。タップで表裏フリップ。

import SwiftUI

struct FlashcardView: View {
    let word: Word
    @State private var isFlipped = false
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                isFlipped.toggle()
            }
        }
        .onChange(of: word) { _, _ in
            isFlipped = false
        }
    }

    // MARK: - 表面

    private var front: some View {
        cardSurface {
            VStack(spacing: 20) {
                header
                Spacer()
                wordWhitePanel(fontSize: 72, includeSpeaker: true)
                Spacer()
                Text("タップで意味を表示")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.tertiaryText)
            }
        }
    }

    // MARK: - 裏面

    private var back: some View {
        cardSurface {
            VStack(spacing: 14) {
                header
                wordWhitePanel(fontSize: 36, includeSpeaker: false)
                Text(word.meaning)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.primaryText)
                exampleBlock
                Spacer()
                VStack(spacing: 8) {
                    NavigationLink {
                        PronunciationCheckView(word: word, target: .word)
                    } label: {
                        Label("単語の発音チェック", systemImage: "mic.fill")
                            .font(.callout.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppTheme.buttonGradient)
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PronunciationCheckView(word: word, target: .example)
                    } label: {
                        Label("例文の発音練習", systemImage: "text.bubble.fill")
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
        }
    }

    // MARK: - 単語パネル（白背景で漢字＋拼音を表示）

    private func wordWhitePanel(fontSize: CGFloat, includeSpeaker: Bool) -> some View {
        VStack(spacing: 10) {
            Text(word.pinyin)
                .font(.title3)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
            CharactersWithTonesView(word: word, fontSize: fontSize, onLightBackground: true)
            if includeSpeaker {
                speakerButton(text: word.word, audioPath: word.wordAudio)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.lightSurface)
        )
    }

    // MARK: - 例文ブロック（白背景＋左に紫アクセント）

    private var exampleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                ExampleSentenceView(word: word, fontSize: 18, weight: .medium, onLightBackground: true)
                Spacer(minLength: 4)
                speakerButton(text: word.exampleChinese, size: .small)
            }
            Text(word.examplePinyin)
                .font(.callout)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
            Text(word.exampleMeaning)
                .font(.callout)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.lightSurface)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(AppTheme.accent)
                .frame(width: 3)
                .padding(.vertical, 4)
        }
    }

    // MARK: - 共通

    private var header: some View {
        HStack {
            Text(word.level.label)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppTheme.accent.opacity(0.4)))
            Text(word.part)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            favoriteButton
        }
    }

    private var favoriteButton: some View {
        let isFav = favorites.isFavorite(word)
        return Image(systemName: isFav ? "heart.fill" : "heart")
            .font(.title3)
            .foregroundStyle(isFav ? Color(red: 1.0, green: 0.40, blue: 0.55) : AppTheme.secondaryText)
            .padding(8)
            .background(Circle().fill(Color.white.opacity(0.10)))
            .contentShape(Circle())
            .onTapGesture {
                favorites.toggle(word)
            }
    }

    private enum SpeakerSize { case normal, small }

    private func speakerButton(
        text: String,
        audioPath: String? = nil,
        size: SpeakerSize = .normal
    ) -> some View {
        Image(systemName: "speaker.wave.2.fill")
            .font(size == .normal ? .title3 : .callout)
            .foregroundStyle(.white)
            .padding(size == .normal ? 10 : 6)
            .background(Circle().fill(AppTheme.accent.opacity(0.45)))
            .contentShape(Circle())
            .onTapGesture {
                // mp3 が Bundle にあれば再生、無ければ TTS にフォールバック
                if let audioPath, AudioPlayer.shared.play(bundlePath: audioPath) {
                    return
                }
                SpeechSynthesizer.shared.speak(text)
            }
    }

    private func cardSurface<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack { content() }
            .frame(maxWidth: .infinity, minHeight: 460)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(AppTheme.cardStroke, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.5), radius: 18, y: 8)
    }
}

#Preview("表面") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        FlashcardView(word: .preview)
            .padding()
    }
    .environmentObject(FavoritesStore())
    .preferredColorScheme(.dark)
}
