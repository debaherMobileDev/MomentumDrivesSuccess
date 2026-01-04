//
//  OnboardingView.swift
//  Momentum Drives Success
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Momentum Drives Success",
            description: "Your ultimate business task management solution. Streamline projects, collaborate with teams, and drive success with powerful tools designed for professionals.",
            imageName: "checkmark.circle.fill",
            color: AppTheme.accentColor
        ),
        OnboardingPage(
            title: "Manage Projects Effortlessly",
            description: "Create and organize projects with ease. Set priorities, deadlines, and track progress in real-time. Stay on top of every detail with our intuitive dashboard.",
            imageName: "folder.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Collaborate with Your Team",
            description: "Assign tasks to team members, track their progress, and communicate seamlessly within the app. Keep everyone aligned and productive.",
            imageName: "person.3.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Track Performance & Analytics",
            description: "Visualize your productivity with powerful analytics. Generate reports, identify trends, and make data-driven decisions to optimize your workflow.",
            imageName: "chart.bar.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "Never Miss a Deadline",
            description: "Get timely notifications for upcoming deadlines and important updates. Customize alerts to stay informed without being overwhelmed.",
            imageName: "bell.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? AppTheme.accentColor : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 30 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                    }
                    
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.accentColor)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 130, height: 130)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(page.color)
            }
            .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Description
            Text(page.description)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

