//
//  Momentum_Drives_SuccessApp.swift
//  Momentum Drives Success
//
//  Created by Simon Bakhanets on 04.01.2026.
//

//
//  Momentum_Drives_SuccessApp.swift
//  Momentum Drives Success
//

import SwiftUI

@main
struct Momentum_Drives_SuccessApp: App {
    init() {
        // Configure app-wide appearance
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(AppTheme.accentColor)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
