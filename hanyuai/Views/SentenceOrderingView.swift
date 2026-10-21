//
//  SentenceOrderingView.swift
//  hanyuai
//
//  例文の音声または日本語訳を手がかりに、中国語の語句を並べる練習。
//
import SwiftUI
import FirebaseAnalytics

enum SentenceOrderingMode: String, Identifiable, Equatable {
    case listening
    case japanese

    var id: String { rawValue }

    var title: String {
        switch self {
        case .listening: return "音声から並び替え"
        case .japanese: return "日本語から並び替え"
        }
    }

    var icon: String {
        switch self {
        case .listening: return "speaker.wave.2.fill"
        case .japanese: return "text.bubble.fill"
        }
    }

    var instruction: String {
        switch self {
        case .listening: return "例文を聞いて、中国語の語句を並べてください。"
        case .japanese: return "日本語訳を見て、中国語の語句を並べてください。"
        }
    }
}

private struct SentenceOrderingQuestion: Identifiable {
    let word: Word
    let tokens: [String]

    var id: String { word.exampleChinese }
}

private struct SentenceTile: Identifiable {
    let id = UUID()
    let text: String
}

private enum SentenceQuestionFactory {
    private static var cache: [HSKLevel: [SentenceOrderingQuestion]] = [:]

    static func questions(for level: HSKLevel) -> [SentenceOrderingQuestion] {
        if let cached = cache[level] {
            return cached
        }

        let dictionary = Array(Set(WordRepository.all.map(\.word)))
            .filter { !$0.isEmpty }
            .sorted { $0.count > $1.count }

        var seenSentences = Set<String>()
        let result = WordRepository.words(of: level).compactMap { word -> SentenceOrderingQuestion? in
            guard !word.exampleChinese.isEmpty,
                  !word.exampleMeaning.isEmpty,
                  seenSentences.insert(word.exampleChinese).inserted,
                  let tokens = tokenize(word.exampleChinese, dictionary: dictionary),
                  (3...14).contains(tokens.count) else {
                return nil
            }
            return SentenceOrderingQuestion(word: word, tokens: tokens)
        }

        cache[level] = result
        return result
    }

    private static func tokenize(
        _ sentence: String,
        dictionary: [String]
    ) -> [String]? {
        var tokens: [String] = []
        var index = sentence.startIndex

        while index < sentence.endIndex {
            let character = sentence[index]
            if character.isWhitespace {
                index = sentence.index(after: index)
                continue
            }

            let isPunctuation = String(character).unicodeScalars.allSatisfy {
                CharacterSet.punctuationCharacters.contains($0)
            }
            if isPunctuation {
                if !tokens.isEmpty {
                    tokens[tokens.count - 1] += String(character)
                }
                index = sentence.index(after: index)
                continue
            }

            let remainder = sentence[index...]
            guard let token = dictionary.first(where: { remainder.hasPrefix($0) }) else {
                return nil
            }
            tokens.append(token)
            index = sentence.index(index, offsetBy: token.count)
        }

        return tokens
    }
}

struct SentenceOrderingView: View {
    let mode: SentenceOrderingMode

    @EnvironmentObject private var session: ChatSession

    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: HSKLevel = .hsk1
    @State private var questions: [SentenceOrderingQuestion] = []
    @State private var currentIndex = 0
    @State private var shuffledTiles: [SentenceTile] = []
    @State private var arrangedTileIDs: [UUID] = []
    @State private var hasAnswered = false
    @State private var isCorrect = false
    @State private var wrongQuestionIDs = Set<String>()
    @State private var hasStarted = false
    @State private var didLogCompletion = false

    private var availableCount: Int {
        SentenceQuestionFactory.questions(for: selectedLevel).count
    }

    private var currentQuestion: SentenceOrderingQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    private var arrangedTiles: [SentenceTile] {
        let tileByID = Dictionary(uniqueKeysWithValues: shuffledTiles.map { ($0.id, $0) })
        return arrangedTileIDs.compactMap { tileByID[$0] }
    }

    private var remainingTiles: [SentenceTile] {
        shuffledTiles.filter { !arrangedTileIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            Group {
                if !hasStarted {
                    setupScreen
                } else if currentIndex >= questions.count {
                    resultScreen
                } else if let question = currentQuestion {
                    questionScreen(question)
                }
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var setupScreen: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                Image(systemName: mode.icon)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                Text(mode.instruction)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.primaryText)
                Text("登録されている例文を組み立てます。別の自然な言い方もあります。")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .glassCard()

            VStack(alignment: .leading, spacing: 12) {
                Text("出題レベル")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)

                Picker("出題レベル", selection: $selectedLevel) {
                    ForEach(HSKLevel.allCases) { level in
                        Text(level.label).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Text("\(availableCount)文から10問を出題します")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()

            Spacer()

            Button(action: startSession) {
                Text("10問を始める")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppTheme.buttonGradient)
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(availableCount == 0)
            .opacity(availableCount == 0 ? 0.5 : 1)
        }
        .padding(20)
    }

    private func questionScreen(_ question: SentenceOrderingQuestion) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(currentIndex + 1) / \(questions.count)")
                    .font(.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text(question.word.level.label)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppTheme.accent.opacity(0.4)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ProgressView(value: Double(currentIndex + 1), total: Double(questions.count))
                .tint(AppTheme.accent)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    promptCard(for: question)
                    if hasAnswered {
                        answerFeedback(for: question)
                    }
                    tileArea
                }
                .padding(20)
            }

            if hasAnswered {
                Button(action: advance) {
                    Text(currentIndex == questions.count - 1 ? "結果を見る" : "次の問題へ")
                        .primaryButtonBackground()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            } else {
                Button(action: checkAnswer) {
                    Text("答え合わせ")
                        .primaryButtonBackground()
                }
                .buttonStyle(.plain)
                .disabled(arrangedTileIDs.count != question.tokens.count)
                .opacity(arrangedTileIDs.count == question.tokens.count ? 1 : 0.5)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }

            if !session.isPremium {
                BannerAdView(adUnitID: AdUnitID.banner)
                    .frame(height: 50)
            }
        }
    }

    @ViewBuilder
    private func promptCard(for question: SentenceOrderingQuestion) -> some View {
        VStack(spacing: 14) {
            Text(mode.instruction)
                .font(.subheadline)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                .multilineTextAlignment(.center)

            if mode == .listening {
                Button {
                    playExample(question.word)
                } label: {
                    Label("例文を聞く", systemImage: "speaker.wave.2.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppTheme.buttonGradient)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            } else {
                Text(question.word.exampleMeaning)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.lightSurfaceText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.lightSurface)
        )
    }

    private var tileArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("並べる語句")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Button("消去") {
                    arrangedTileIDs = []
                }
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText)
                .disabled(hasAnswered || arrangedTileIDs.isEmpty)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 74), alignment: .leading)], alignment: .leading, spacing: 8) {
                ForEach(arrangedTiles) { tile in
                    Button {
                        removeTile(tile)
                    } label: {
                        tileLabel(tile.text, selected: true)
                    }
                    .buttonStyle(.plain)
                    .disabled(hasAnswered)
                }
            }
            .frame(minHeight: 52, alignment: .topLeading)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.07))
            )

            Text("選択肢")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 74), alignment: .leading)], alignment: .leading, spacing: 8) {
                ForEach(remainingTiles) { tile in
                    Button {
                        selectTile(tile)
                    } label: {
                        tileLabel(tile.text, selected: false)
                    }
                    .buttonStyle(.plain)
                    .disabled(hasAnswered)
                }
            }
        }
    }

    private func tileLabel(_ text: String, selected: Bool) -> some View {
        Text(text)
            .font(.body.weight(.medium))
            .foregroundStyle(selected ? AppTheme.lightSurfaceText : AppTheme.primaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minWidth: 54)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(selected ? AppTheme.lightSurface : Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(selected ? AppTheme.accent.opacity(0.6) : Color.white.opacity(0.18), lineWidth: 1)
            )
    }

    private func answerFeedback(for question: SentenceOrderingQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(isCorrect ? "正解" : "正解の例文", systemImage: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.headline)
                .foregroundStyle(isCorrect ? .green : AppTheme.accent)

            VStack(alignment: .leading, spacing: 6) {
                Text("中国語")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                Text(question.word.exampleChinese)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.lightSurfaceText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("日本語訳")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                Text(question.word.exampleMeaning)
                    .font(.body)
                    .foregroundStyle(AppTheme.lightSurfaceText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(question.word.examplePinyin)
                .font(.callout)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Text("今回の単語：\(question.word.word)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
                Button {
                    playExample(question.word)
                } label: {
                    Label("音声を聞く", systemImage: "speaker.wave.2.fill")
                        .font(.caption.bold())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.lightSurface)
        )
    }

    private var resultScreen: some View {
        let correctCount = questions.count - wrongQuestionIDs.count
        return VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 54))
                .foregroundStyle(AppTheme.accent)

            Text("練習おつかれさまでした")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)

            Text("例文どおり：\(correctCount) / \(questions.count)問")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.primaryText)

            if !wrongQuestionIDs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("復習する文")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)
                    ForEach(questions.filter { wrongQuestionIDs.contains($0.id) }) { question in
                        Text("\(question.word.exampleChinese) — \(question.word.exampleMeaning)")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .glassCard()

                Button("例文と一致しなかった文を復習") {
                    questions = questions.filter { wrongQuestionIDs.contains($0.id) }
                    currentIndex = 0
                    wrongQuestionIDs = []
                    didLogCompletion = false
                    resetQuestion()
                }
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
            }

            Button {
                dismiss()
            } label: {
                Text("ホームに戻る")
                    .primaryButtonBackground()
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .onAppear {
            guard !didLogCompletion else { return }
            didLogCompletion = true
            Analytics.logEvent("sentence_ordering_completed", parameters: [
                "mode": mode.rawValue,
                "level": selectedLevel.label,
                "correct": questions.count - wrongQuestionIDs.count,
                "total": questions.count
            ])
        }
    }

    private func startSession() {
        questions = Array(SentenceQuestionFactory.questions(for: selectedLevel).shuffled().prefix(10))
        guard !questions.isEmpty else { return }
        currentIndex = 0
        wrongQuestionIDs = []
        didLogCompletion = false
        hasStarted = true
        resetQuestion()
        Analytics.logEvent("sentence_ordering_started", parameters: [
            "mode": mode.rawValue,
            "level": selectedLevel.label,
            "question_count": questions.count
        ])
    }

    private func selectTile(_ tile: SentenceTile) {
        guard !hasAnswered else { return }
        arrangedTileIDs.append(tile.id)
    }

    private func removeTile(_ tile: SentenceTile) {
        guard !hasAnswered else { return }
        arrangedTileIDs.removeAll { $0 == tile.id }
    }

    private func checkAnswer() {
        guard let question = currentQuestion else { return }
        let answer = arrangedTiles.map(\.text)
        isCorrect = answer == question.tokens
        hasAnswered = true
        if !isCorrect {
            wrongQuestionIDs.insert(question.id)
        }
        Analytics.logEvent("sentence_ordering_answered", parameters: [
            "mode": mode.rawValue,
            "level": selectedLevel.label,
            "correct": isCorrect
        ])
    }

    private func advance() {
        currentIndex += 1
        resetQuestion()
    }

    private func resetQuestion() {
        guard questions.indices.contains(currentIndex) else { return }
        let tokens = questions[currentIndex].tokens.map { SentenceTile(text: $0) }
        shuffledTiles = tokens.shuffled()
        arrangedTileIDs = []
        hasAnswered = false
        isCorrect = false
    }

    /// HSK1〜4すべて、例文テキストを合成音声で読む。
    /// 再生前に前の音声を止め、設問と音声が混ざらないようにする。
    private func playExample(_ word: Word) {
        AudioPlayer.shared.stop()
        SpeechSynthesizer.shared.stop()
        SpeechSynthesizer.shared.speak(word.exampleChinese)
    }
}

#Preview {
    NavigationStack {
        SentenceOrderingView(mode: .listening)
    }
    .environmentObject(ChatSession())
    .preferredColorScheme(.dark)
}
