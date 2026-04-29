//
//  LevelTestViewModel.swift
//  hanyuai
//
//  10問のレベル診断テストの状態管理。

import Foundation
import Combine

@MainActor
final class LevelTestViewModel: ObservableObject {
    @Published private(set) var questions: [LevelTestQuestion] = []
    @Published var currentIndex: Int = 0
    @Published private(set) var answers: [Int?] = []
    @Published var isFinished: Bool = false

    /// 各レベルから何問抽出するか（合計10問）
    private let distribution: [HSKLevel: Int] = [
        .hsk1: 3, .hsk2: 3, .hsk3: 2, .hsk4: 2
    ]

    init() {
        regenerate()
    }

    func regenerate() {
        var generated: [LevelTestQuestion] = []
        for level in HSKLevel.allCases {
            let pool = WordRepository.words(of: level)
            let count = distribution[level] ?? 0
            let targets = pool.shuffled().prefix(count)

            for target in targets {
                let wrongPool = WordRepository.all
                    .filter { $0.id != target.id && $0.meaning != target.meaning }
                    .shuffled()
                    .prefix(3)
                    .map(\.meaning)

                var options = [target.meaning] + wrongPool
                options.shuffle()
                let correctIndex = options.firstIndex(of: target.meaning) ?? 0
                generated.append(
                    LevelTestQuestion(target: target, options: options, correctIndex: correctIndex)
                )
            }
        }
        generated.shuffle()
        questions = generated
        answers = Array(repeating: nil, count: generated.count)
        currentIndex = 0
        isFinished = false
    }

    var current: LevelTestQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    func answer(_ optionIndex: Int) {
        guard answers.indices.contains(currentIndex) else { return }
        answers[currentIndex] = optionIndex
    }

    func goNext() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }

    // MARK: - 集計

    var correctCount: Int {
        zip(questions, answers).reduce(0) { acc, pair in
            acc + (pair.1 == pair.0.correctIndex ? 1 : 0)
        }
    }

    var totalCount: Int { questions.count }

    /// レベル別の正答率
    func breakdown() -> [(level: HSKLevel, correct: Int, total: Int)] {
        var dict: [HSKLevel: (Int, Int)] = [:]
        for (q, a) in zip(questions, answers) {
            var entry = dict[q.target.level] ?? (0, 0)
            entry.1 += 1
            if a == q.correctIndex { entry.0 += 1 }
            dict[q.target.level] = entry
        }
        return HSKLevel.allCases.map { level in
            let entry = dict[level] ?? (0, 0)
            return (level, entry.0, entry.1)
        }
    }

    /// 推奨レベル: 正答率が 60% 以上の最高レベルの一つ上を推奨。
    /// 全部60%未満ならHSK1。全部高ければHSK4をそのまま。
    var recommendedLevel: HSKLevel {
        let stats = breakdown()
        let passed = stats.filter { $0.total > 0 && Double($0.correct) / Double($0.total) >= 0.6 }
        guard let topPassed = passed.last?.level else { return .hsk1 }
        switch topPassed {
        case .hsk1: return .hsk2
        case .hsk2: return .hsk3
        case .hsk3: return .hsk4
        case .hsk4: return .hsk4
        }
    }
}
