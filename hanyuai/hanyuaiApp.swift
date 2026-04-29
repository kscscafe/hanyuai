//
//  hanyuaiApp.swift
//  hanyuai
//
//  Created by 杉崎康隆 on 2026/04/28.
//

import SwiftUI
import FirebaseCore

@main
struct hanyuaiApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
        }
    }
}
