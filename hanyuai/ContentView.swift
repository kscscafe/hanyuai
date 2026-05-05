//
//  ContentView.swift
//  hanyuai
//
//  Created by 杉崎康隆 on 2026/04/28.
//

import SwiftUI
import AppTrackingTransparency

struct ContentView: View {
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var chatSession = ChatSession()
    @StateObject private var storeManager = StoreKitManager()
    @ObservedObject private var profile = UserProfile.shared

    var body: some View {
        Group {
            if profile.isOnboardingCompleted {
                HomeView()
                    .environmentObject(favorites)
                    .environmentObject(chatSession)
                    .environmentObject(storeManager)
                    .task {
                        chatSession.bindStoreManager(storeManager)
                    }
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            // 起動直後すぎるとシステム側の準備が整っておらずダイアログが
            // 出ないことがあるため、1秒遅延させる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
            }
        }
    }
}

#Preview {
    ContentView()
}
