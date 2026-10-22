//
//  HomeView.swift
//  hanyuai
//
//  学び方ガイドをホーム画面として表示する。

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            LearningGuideView()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(FavoritesStore())
        .environmentObject(ChatSession())
        .preferredColorScheme(.dark)
}
