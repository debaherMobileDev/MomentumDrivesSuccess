//
//  SettingsView.swift
//  Momentum Drives Success
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataService = DataService.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingDeleteAlert = false
    @State private var showingAbout = false
    @State private var showingHelp = false
    
    var currentUser: TeamMember? {
        dataService.getTeamMember(byId: dataService.appData.currentUserId)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        profileSection
                        
                        // App Settings
                        appSettingsSection
                        
                        // Help & Support
                        helpSection
                        
                        // Account Management
                        accountSection
                        
                        // App Info
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Reset Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataService.resetAllData()
                hasCompletedOnboarding = false
            }
        } message: {
            Text("This will delete all your data including projects, tasks, and team members. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }
    
    var profileSection: some View {
        VStack(spacing: 16) {
            if let user = currentUser {
                ZStack {
                    Circle()
                        .fill(Color(user.avatarColor))
                        .frame(width: 100, height: 100)
                    
                    Text(user.initials)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(user.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(user.email)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(user.role.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.accentColor)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
    
    var appSettingsSection: some View {
        VStack(spacing: 0) {
            Text("App Settings")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
            
            VStack(spacing: 1) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    color: .orange,
                    showChevron: true
                ) {
                    // Notification settings
                }
                
                SettingsRow(
                    icon: "paintbrush.fill",
                    title: "Appearance",
                    color: .purple,
                    showChevron: true
                ) {
                    // Appearance settings
                }
                
                SettingsRow(
                    icon: "lock.fill",
                    title: "Privacy",
                    color: .blue,
                    showChevron: true
                ) {
                    // Privacy settings
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
    
    var helpSection: some View {
        VStack(spacing: 0) {
            Text("Help & Support")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
            
            VStack(spacing: 1) {
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help Center",
                    color: .green,
                    showChevron: true
                ) {
                    showingHelp = true
                }
                
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About",
                    color: .blue,
                    showChevron: true
                ) {
                    showingAbout = true
                }
                
                SettingsRow(
                    icon: "arrow.counterclockwise",
                    title: "Restart Tutorial",
                    color: .purple,
                    showChevron: false
                ) {
                    hasCompletedOnboarding = false
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
    
    var accountSection: some View {
        VStack(spacing: 0) {
            Text("Account")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
            
            VStack(spacing: 1) {
                SettingsRow(
                    icon: "arrow.clockwise.circle.fill",
                    title: "Reset App Data",
                    color: .orange,
                    showChevron: false
                ) {
                    showingDeleteAlert = true
                }
                
                SettingsRow(
                    icon: "trash.fill",
                    title: "Delete Account",
                    color: .red,
                    showChevron: false
                ) {
                    showingDeleteAlert = true
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
    
    var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("Momentum Drives Success")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Version 1.0.0")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
            
            Text("© 2026 Momentum Drives Success")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let showChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.accentColor)
                            .padding(.top, 40)
                        
                        Text("Momentum Drives Success")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About This App")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Momentum Drives Success is a premium business task management application designed for professionals who demand excellence in project organization and team collaboration.")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .lineSpacing(4)
                            
                            Text("Features:")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.top, 8)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "checkmark.circle.fill", text: "Comprehensive project management")
                                FeatureRow(icon: "person.3.fill", text: "Team collaboration & messaging")
                                FeatureRow(icon: "chart.bar.fill", text: "Advanced analytics & reporting")
                                FeatureRow(icon: "bell.fill", text: "Smart notifications & alerts")
                                FeatureRow(icon: "lock.fill", text: "Secure data storage")
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(AppTheme.cornerRadius)
                        
                        Text("© 2026 Momentum Drives Success\nAll rights reserved.")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accentColor)
                }
            }
        }
    }
}

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    let helpTopics = [
        HelpTopic(
            icon: "folder.fill",
            title: "Creating Projects",
            description: "Tap the '+' button in the dashboard to create a new project. Fill in the project details, set deadlines, and assign team members."
        ),
        HelpTopic(
            icon: "checkmark.circle.fill",
            title: "Managing Tasks",
            description: "Create tasks within projects or standalone. Set priorities, deadlines, and assign to team members. Track progress by updating task status."
        ),
        HelpTopic(
            icon: "person.3.fill",
            title: "Team Collaboration",
            description: "Add team members to your workspace. Assign tasks, send messages, and track individual performance through the Team tab."
        ),
        HelpTopic(
            icon: "chart.bar.fill",
            title: "Analytics & Reports",
            description: "View comprehensive analytics in the Analytics tab. Track completion rates, team performance, and project progress over time."
        ),
        HelpTopic(
            icon: "bell.fill",
            title: "Notifications",
            description: "Stay updated with smart notifications for upcoming deadlines and team messages. Customize notification settings in Settings."
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(helpTopics) { topic in
                            HelpTopicCard(topic: topic)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Help Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accentColor)
                }
            }
        }
    }
}

struct HelpTopic: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct HelpTopicCard: View {
    let topic: HelpTopic
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: topic.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.accentColor)
                
                Text(topic.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Text(topic.description)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.accentColor)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

