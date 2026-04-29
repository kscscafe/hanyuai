//
//  PronunciationJudge.swift
//  hanyuai
//
//  認識結果と正解の中国語文字列を比較して点数化する。
//  シンプルな文字一致率ベース（後で外部AI判定 API に差し替え可能）。

import Foundation

enum PronunciationVerdict: Equatable {
    case excellent   // 完全一致
    case good        // 80%以上
    case fair        // 50%以上
    case poor        // それ未満

    var label: String {
        switch self {
        case .excellent: return "完璧！"
        case .good:      return "良好"
        case .fair:      return "もう少し"
        case .poor:      return "再挑戦"
        }
    }

    var symbol: String {
        switch self {
        case .excellent: return "checkmark.circle.fill"
        case .good:      return "hand.thumbsup.fill"
        case .fair:      return "exclamationmark.circle.fill"
        case .poor:      return "arrow.clockwise.circle.fill"
        }
    }
}

enum PronunciationJudge {
    struct Result {
        var verdict: PronunciationVerdict
        var score: Double          // 0.0 - 1.0
        var heard: String          // 認識結果（句読点除去後）
        var expected: String       // 期待値（句読点除去後）
    }

    static func evaluate(expected: String, heard: String) -> Result {
        let exp = normalize(expected)
        let got = normalize(heard)
        let score = similarity(a: exp, b: got)

        let verdict: PronunciationVerdict
        if exp == got && !exp.isEmpty {
            verdict = .excellent
        } else if score >= 0.8 {
            verdict = .good
        } else if score >= 0.5 {
            verdict = .fair
        } else {
            verdict = .poor
        }
        return Result(verdict: verdict, score: score, heard: got, expected: exp)
    }

    /// 句読点・空白・声調記号などを除去して比較しやすくする。
    private static func normalize(_ text: String) -> String {
        let stripped = text.unicodeScalars.filter { scalar in
            !CharacterSet.whitespacesAndNewlines.contains(scalar)
                && !CharacterSet.punctuationCharacters.contains(scalar)
                && !CharacterSet.symbols.contains(scalar)
        }
        return String(String.UnicodeScalarView(stripped))
    }

    /// 文字単位での一致率（最長共通部分列ベース）。0.0〜1.0。
    private static func similarity(a: String, b: String) -> Double {
        guard !a.isEmpty && !b.isEmpty else { return 0 }
        let lcs = longestCommonSubsequenceLength(Array(a), Array(b))
        let denom = max(a.count, b.count)
        return Double(lcs) / Double(denom)
    }

    private static func longestCommonSubsequenceLength(_ a: [Character], _ b: [Character]) -> Int {
        let n = a.count, m = b.count
        if n == 0 || m == 0 { return 0 }
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 1...n {
            for j in 1...m {
                if a[i - 1] == b[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }
        return dp[n][m]
    }
}
