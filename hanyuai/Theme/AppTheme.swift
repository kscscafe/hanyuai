//
//  AppTheme.swift
//  hanyuai
//
//  アプリ全体の配色・グラデーション・カードスタイルを集中管理する。

import SwiftUI

enum AppTheme {
    // MARK: - 背景・カード（ダークグレー基調）

    /// メイン背景 #1C1C1E（iOS systemBackground 相当のダーク）
    static let background = Color(red: 0x1C / 255, green: 0x1C / 255, blue: 0x1E / 255)

    /// カード背景 #2C2C2E
    static let cardBackground = Color(red: 0x2C / 255, green: 0x2C / 255, blue: 0x2E / 255)

    /// カード上で一段強調したいセクションの背景 #3A3A3C
    static let elevatedBackground = Color(red: 0x3A / 255, green: 0x3A / 255, blue: 0x3C / 255)

    /// カード内に置く白パネルの背景・テキスト色
    static let lightSurface = Color.white
    static let lightSurfaceText = Color.black.opacity(0.88)
    static let lightSurfaceSecondaryText = Color.black.opacity(0.60)

    /// ナビゲーションバー（背景と同色）
    static let navigationBar = background

    // MARK: - アクセント（ボタン等のグラデーション）

    static let buttonGradient = LinearGradient(
        colors: [
            Color(red: 0.45, green: 0.32, blue: 0.92), // パープル
            Color(red: 0.32, green: 0.55, blue: 0.95), // ブルー
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pinkGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.35, blue: 0.55),
            Color(red: 0.65, green: 0.30, blue: 0.85),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(red: 0.55, green: 0.45, blue: 0.95)

    // MARK: - テキスト
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.72)
    static let tertiaryText = Color.white.opacity(0.50)

    // MARK: - 罫線
    static let cardStroke = Color.white.opacity(0.08)
}

// MARK: - 共通モディファイア

extension View {
    /// 画面全体の背景色（ダークグレー）。NavigationStack 内のルートに使う。
    func appBackground() -> some View {
        background(AppTheme.background.ignoresSafeArea())
    }

    /// カード背景 #2C2C2E + 細い白の縁取り
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(AppTheme.cardStroke, lineWidth: 0.5)
        )
    }

    /// 主要ボタン（パープル〜ブルーグラデーション）
    func primaryButtonBackground(cornerRadius: CGFloat = 14) -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.buttonGradient)
            )
            .foregroundStyle(.white)
            .shadow(color: AppTheme.accent.opacity(0.35), radius: 12, y: 4)
    }
}
