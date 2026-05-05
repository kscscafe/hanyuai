//
//  hanyuaiApp.swift
//  hanyuai
//
//  Created by 杉崎康隆 on 2026/04/28.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct hanyuaiApp: App {
    init() {
        FirebaseApp.configure()
        #if DEBUG
        // SDK v12+ ではシミュレーターは自動でテストデバイス扱い（GADSimulatorID は廃止）。
        // 実機で開発する場合は、初回起動時のログに出る "Use ... to get test ads on this device."
        // のIDをここに追加すること。
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = []
        #endif
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
        }
    }
}
