//
//  ContentView.swift
//  Momentum Drives Success
//
//  Created by Simon Bakhanets on 04.01.2026.
//

//
//  ContentView.swift
//  Momentum Drives Success
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                    .tag(0)
                
                ProjectsListView()
                    .tabItem {
                        Label("Projects", systemImage: "folder.fill")
                    }
                    .tag(1)
                
                TeamView()
                    .tabItem {
                        Label("Team", systemImage: "person.3.fill")
                    }
                    .tag(2)
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }
                    .tag(3)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
            .accentColor(AppTheme.accentColor)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(AppTheme.cardBackground)
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.textSecondary)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.textSecondary)]
                
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.accentColor)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.accentColor)]
                
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
                
                // Navigation Bar Appearance
                let navAppearance = UINavigationBarAppearance()
                navAppearance.configureWithOpaqueBackground()
                navAppearance.backgroundColor = UIColor(AppTheme.cardBackground)
                navAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.textPrimary)]
                navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppTheme.textPrimary)]
                
                UINavigationBar.appearance().standardAppearance = navAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                UINavigationBar.appearance().compactAppearance = navAppearance
            }
        }
    }
}

#Preview {
    ContentView()
}
