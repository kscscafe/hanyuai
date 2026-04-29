//
//  LevelTestView.swift
//  hanyuai
//
//  10問のレベル診断テスト出題画面。

import SwiftUI

struct LevelTestView: View {
    @StateObject private var viewModel = LevelTestViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            Group {
                if viewModel.isFinished {
                    LevelTestResultView(viewModel: viewModel)
                } else {
                    questionScreen
                }
            }
        }
        .navigationTitle("レベル診断")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - 出題画面

    private var questionScreen: some View {
        VStack(spacing: 16) {
            progressHeader
            if let question = viewModel.current {
                ScrollView {
                    VStack(spacing: 24) {
                        questionCard(for: question)
                        optionsList(for: question)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
                nextButton(for: question)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            } else {
                Spacer()
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(viewModel.currentIndex + 1) / \(viewModel.totalCount)")
                    .font(.callout)
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                if let q = viewModel.current {
                    Text(q.target.level.label)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.accent.opacity(0.4)))
                }
            }
            ProgressView(
                value: Double(viewModel.currentIndex + 1),
                total: Double(viewModel.totalCount)
            )
            .tint(AppTheme.accent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func questionCard(for question: LevelTestQuestion) -> some View {
        VStack(spacing: 12) {
            Text("この単語の意味は？")
                .font(.subheadline)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
            CharactersWithTonesView(word: question.target, fontSize: 64, onLightBackground: true)
            Text(question.target.pinyin)
                .font(.title3)
                .foregroundStyle(AppTheme.lightSurfaceSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.lightSurface)
        )
    }

    private func optionsList(for question: LevelTestQuestion) -> some View {
        let selected = viewModel.answers[viewModel.currentIndex]
        return VStack(spacing: 10) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                optionRow(
                    index: index,
                    text: option,
                    selected: selected == index,
                    isCorrect: index == question.correctIndex,
                    revealed: selected != nil
                )
                .onTapGesture {
                    if selected == nil {
                        withAnimation(.easeOut(duration: 0.15)) {
                            viewModel.answer(index)
                        }
                    }
                }
            }
        }
    }

    private func optionRow(
        index: Int,
        text: String,
        selected: Bool,
        isCorrect: Bool,
        revealed: Bool
    ) -> some View {
        let bg: Color = {
            guard revealed else { return Color.white.opacity(0.08) }
            if isCorrect { return Color.green.opacity(0.30) }
            if selected { return Color.red.opacity(0.30) }
            return Color.white.opacity(0.08)
        }()
        let borderColor: Color = {
            guard revealed else { return Color.white.opacity(0.18) }
            if isCorrect { return Color.green.opacity(0.6) }
            if selected { return Color.red.opacity(0.6) }
            return Color.white.opacity(0.18)
        }()
        let icon: String? = {
            guard revealed else { return nil }
            if isCorrect { return "checkmark.circle.fill" }
            if selected { return "xmark.circle.fill" }
            return nil
        }()
        return HStack {
            Text(text)
                .font(.body)
                .foregroundStyle(AppTheme.primaryText)
            Spacer()
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(isCorrect ? .green : .red)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(bg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.6)
        )
        .contentShape(Rectangle())
    }

    private func nextButton(for question: LevelTestQuestion) -> some View {
        let answered = viewModel.answers[viewModel.currentIndex] != nil
        let isLast = viewModel.currentIndex == viewModel.totalCount - 1
        return Button {
            viewModel.goNext()
        } label: {
            Text(isLast ? "結果を見る" : "次の問題へ")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(answered ? AnyShapeStyle(AppTheme.buttonGradient)
                                       : AnyShapeStyle(Color.white.opacity(0.15)))
                )
                .foregroundStyle(answered ? .white : AppTheme.tertiaryText)
                .shadow(color: answered ? AppTheme.accent.opacity(0.35) : .clear, radius: 12, y: 4)
        }
        .disabled(!answered)
    }
}

#Preview {
    NavigationStack { LevelTestView() }
        .environmentObject(FavoritesStore())
        .preferredColorScheme(.dark)
}
