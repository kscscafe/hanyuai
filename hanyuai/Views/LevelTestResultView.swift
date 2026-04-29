//
//  LevelTestResultView.swift
//  hanyuai
//
//  レベル診断テストの結果画面。

import SwiftUI
import FirebaseAnalytics

struct LevelTestResultView: View {
    @ObservedObject var viewModel: LevelTestViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                summaryCard
                breakdownSection
                actions
            }
            .padding(20)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("診断結果")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Analytics.logEvent(
                "level_test_completed",
                parameters: ["result": viewModel.recommendedLevel.label]
            )
        }
    }

    // MARK: - 総合スコア

    private var summaryCard: some View {
        VStack(spacing: 12) {
            Text("正答 \(viewModel.correctCount) / \(viewModel.totalCount)")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText)
            ProgressView(
                value: Double(viewModel.correctCount),
                total: Double(max(viewModel.totalCount, 1))
            )
            .tint(AppTheme.accent)
            Divider().overlay(Color.white.opacity(0.15))
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("おすすめレベル")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(viewModel.recommendedLevel.label)
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.primaryText)
                }
                Spacer()
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 18)
    }

    // MARK: - レベル別

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("レベル別正答率")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)
            ForEach(viewModel.breakdown(), id: \.level) { entry in
                breakdownRow(level: entry.level, correct: entry.correct, total: entry.total)
            }
        }
        .padding(16)
        .glassCard()
    }

    private func breakdownRow(level: HSKLevel, correct: Int, total: Int) -> some View {
        let ratio = total == 0 ? 0 : Double(correct) / Double(total)
        return HStack(spacing: 12) {
            Text(level.label)
                .font(.callout.bold())
                .foregroundStyle(AppTheme.primaryText)
                .frame(width: 56, alignment: .leading)
            ProgressView(value: ratio)
                .tint(barColor(level))
            Text("\(correct) / \(total)")
                .font(.callout.monospacedDigit())
                .foregroundStyle(AppTheme.secondaryText)
                .frame(width: 56, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }

    private func barColor(_ level: HSKLevel) -> Color {
        switch level {
        case .hsk1: return Color(red: 0.55, green: 0.85, blue: 0.65)
        case .hsk2: return Color(red: 0.40, green: 0.65, blue: 1.0)
        case .hsk3: return Color(red: 1.0, green: 0.65, blue: 0.30)
        case .hsk4: return Color(red: 1.0, green: 0.40, blue: 0.45)
        }
    }

    // MARK: - アクション

    private var actions: some View {
        VStack(spacing: 12) {
            NavigationLink {
                FlashcardDeckView(
                    words: WordRepository.words(of: viewModel.recommendedLevel),
                    title: "\(viewModel.recommendedLevel.label) の練習",
                    deckID: viewModel.recommendedLevel.label
                )
            } label: {
                Text("\(viewModel.recommendedLevel.label) を学習する")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppTheme.buttonGradient)
                    )
                    .foregroundStyle(.white)
                    .shadow(color: AppTheme.accent.opacity(0.35), radius: 12, y: 4)
            }
            .buttonStyle(.plain)

            Button {
                viewModel.regenerate()
            } label: {
                Label("もう一度診断する", systemImage: "arrow.clockwise")
                    .font(.callout.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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

#Preview {
    NavigationStack {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            LevelTestResultView(viewModel: {
                let vm = LevelTestViewModel()
                vm.isFinished = true
                return vm
            }())
        }
    }
    .environmentObject(FavoritesStore())
    .preferredColorScheme(.dark)
}
