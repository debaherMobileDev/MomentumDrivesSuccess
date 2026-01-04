//
//  TeamView.swift
//  Momentum Drives Success
//

import SwiftUI

struct TeamView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var showingAddMember = false
    @State private var showingMessages = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Messages Section
                        messagesSection
                        
                        // Team Members
                        teamMembersSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Team")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMember = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddTeamMemberView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var messagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Messages")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                if dataService.getUnreadMessageCount() > 0 {
                    Text("\(dataService.getUnreadMessageCount())")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentColor)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                NavigationLink(destination: MessagesView()) {
                    Text("View All")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.accentColor)
                }
            }
            
            if dataService.appData.messages.isEmpty {
                EmptyStateView(
                    icon: "message.fill",
                    title: "No Messages",
                    description: "Your team messages will appear here"
                )
            } else {
                ForEach(dataService.appData.messages.prefix(3).sorted(by: { $0.timestamp > $1.timestamp })) { message in
                    MessageRow(message: message)
                }
            }
        }
    }
    
    var teamMembersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Members")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(dataService.appData.teamMembers.filter { $0.isActive }) { member in
                NavigationLink(destination: TeamMemberDetailView(member: member)) {
                    TeamMemberCard(member: member)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct MessageRow: View {
    let message: Message
    @ObservedObject var dataService = DataService.shared
    
    var sender: TeamMember? {
        dataService.getTeamMember(byId: message.senderId)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let sender = sender {
                ZStack {
                    Circle()
                        .fill(Color(sender.avatarColor))
                        .frame(width: 44, height: 44)
                    
                    Text(sender.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(sender?.name ?? "Unknown")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            if !message.isRead {
                Circle()
                    .fill(AppTheme.accentColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

struct TeamMemberCard: View {
    let member: TeamMember
    @ObservedObject var dataService = DataService.shared
    
    var assignedTasksCount: Int {
        dataService.appData.tasks.filter { $0.assignedToId == member.id && $0.status != .completed }.count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(member.avatarColor))
                    .frame(width: 56, height: 56)
                
                Text(member.initials)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(member.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(member.role.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                
                if assignedTasksCount > 0 {
                    Text("\(assignedTasksCount) active tasks")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.accentColor)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct AddTeamMemberView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var role: MemberRole = .developer
    @State private var avatarColor = "blue"
    
    let colors = ["blue", "green", "purple", "orange", "pink", "red", "yellow"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar Preview
                        ZStack {
                            Circle()
                                .fill(Color(avatarColor))
                                .frame(width: 100, height: 100)
                            
                            if !name.isEmpty {
                                Text(TeamMember(name: name, email: email, role: role, avatarColor: avatarColor).initials)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Avatar Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Avatar Color")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: 16) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(AppTheme.accentColor, lineWidth: avatarColor == color ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            avatarColor = color
                                        }
                                }
                            }
                        }
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("Enter name", text: $name)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("Enter email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Role
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Role")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Role", selection: $role) {
                                ForEach(MemberRole.allCases, id: \.self) { role in
                                    Text(role.rawValue).tag(role)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Add Button
                        Button(action: addMember) {
                            Text("Add Team Member")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(name.isEmpty || email.isEmpty ? Color.gray : AppTheme.accentColor)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .disabled(name.isEmpty || email.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
    
    func addMember() {
        let newMember = TeamMember(
            name: name,
            email: email,
            role: role,
            avatarColor: avatarColor
        )
        
        dataService.addTeamMember(newMember)
        dismiss()
    }
}

