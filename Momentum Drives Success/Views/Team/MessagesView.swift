//
//  MessagesView.swift
//  Momentum Drives Success
//

import SwiftUI

struct MessagesView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var showingNewMessage = false
    
    var sortedMessages: [Message] {
        dataService.appData.messages.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            if sortedMessages.isEmpty {
                EmptyStateView(
                    icon: "message.fill",
                    title: "No Messages",
                    description: "Start a conversation with your team"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedMessages) { message in
                            MessageDetailRow(message: message)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewMessage = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingNewMessage) {
            NewMessageView()
        }
    }
}

struct MessageDetailRow: View {
    let message: Message
    @ObservedObject var dataService = DataService.shared
    
    var sender: TeamMember? {
        dataService.getTeamMember(byId: message.senderId)
    }
    
    var project: Project? {
        if let projectId = message.projectId {
            return dataService.getProject(byId: projectId)
        }
        return nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let sender = sender {
                ZStack {
                    Circle()
                        .fill(Color(sender.avatarColor))
                        .frame(width: 50, height: 50)
                    
                    Text(sender.initials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(sender?.name ?? "Unknown")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Text(message.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                if let project = project {
                    Text("Re: \(project.name)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.accentColor)
                }
                
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(4)
                
                if !message.isRead {
                    HStack {
                        Circle()
                            .fill(AppTheme.accentColor)
                            .frame(width: 6, height: 6)
                        
                        Text("New")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.accentColor)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .onTapGesture {
            if !message.isRead {
                dataService.markMessageAsRead(message.id)
            }
        }
    }
}

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var selectedRecipient: TeamMember?
    @State private var selectedProject: Project?
    @State private var messageContent = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Recipient
                        VStack(alignment: .leading, spacing: 8) {
                            Text("To")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Recipient", selection: $selectedRecipient) {
                                Text("Select recipient").tag(nil as TeamMember?)
                                ForEach(dataService.appData.teamMembers.filter { $0.id != dataService.appData.currentUserId }, id: \.self) { member in
                                    Text(member.name).tag(member as TeamMember?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Project (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project (Optional)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Project", selection: $selectedProject) {
                                Text("None").tag(nil as Project?)
                                ForEach(dataService.appData.projects, id: \.self) { project in
                                    Text(project.name).tag(project as Project?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextEditor(text: $messageContent)
                                .frame(height: 200)
                                .padding(8)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Send Button
                        Button(action: sendMessage) {
                            Text("Send Message")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background((selectedRecipient == nil || messageContent.isEmpty) ? Color.gray : AppTheme.accentColor)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .disabled(selectedRecipient == nil || messageContent.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Message")
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
    
    func sendMessage() {
        guard let recipient = selectedRecipient else { return }
        
        let newMessage = Message(
            senderId: dataService.appData.currentUserId,
            recipientId: recipient.id,
            projectId: selectedProject?.id,
            content: messageContent
        )
        
        dataService.addMessage(newMessage)
        dismiss()
    }
}

