//
//  TeamMemberDetailView.swift
//  Momentum Drives Success
//

import SwiftUI

struct TeamMemberDetailView: View {
    let member: TeamMember
    @ObservedObject var dataService = DataService.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var assignedTasks: [Task] {
        dataService.appData.tasks.filter { $0.assignedToId == member.id }
    }
    
    var activeTasks: [Task] {
        assignedTasks.filter { $0.status != .completed }
    }
    
    var completedTasks: [Task] {
        assignedTasks.filter { $0.status == .completed }
    }
    
    var totalHours: Double {
        assignedTasks.reduce(0) { $0 + $1.actualHours }
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(member.avatarColor))
                                .frame(width: 100, height: 100)
                            
                            Text(member.initials)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(member.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(member.role.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(member.email)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.accentColor)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    
                    // Stats
                    HStack(spacing: 12) {
                        StatBox(title: "Active", value: "\(activeTasks.count)", color: .blue)
                        StatBox(title: "Completed", value: "\(completedTasks.count)", color: .green)
                        StatBox(title: "Hours", value: "\(Int(totalHours))", color: .orange)
                    }
                    
                    // Details
                    VStack(spacing: 12) {
                        DetailRow(
                            icon: "calendar",
                            title: "Joined",
                            value: member.joinDate.formatted(date: .long, time: .omitted),
                            color: .blue
                        )
                        
                        DetailRow(
                            icon: member.isActive ? "checkmark.circle.fill" : "xmark.circle.fill",
                            title: "Status",
                            value: member.isActive ? "Active" : "Inactive",
                            color: member.isActive ? .green : .gray
                        )
                    }
                    
                    // Tasks
                    if !assignedTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Assigned Tasks")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            ForEach(assignedTasks.sorted(by: { $0.deadline < $1.deadline })) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskRow(task: task)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: { showingEditSheet = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Member")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.accentColor)
                            .cornerRadius(AppTheme.cornerRadius)
                        }
                        
                        if member.id != dataService.appData.currentUserId {
                            Button(action: { showingDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "person.fill.xmark")
                                    Text("Remove Member")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.cornerRadius)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Team Member")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditTeamMemberView(member: member)
        }
        .alert("Remove Team Member", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                dataService.deleteTeamMember(member)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to remove \(member.name) from the team?")
        }
    }
}

struct EditTeamMemberView: View {
    let member: TeamMember
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var name: String
    @State private var email: String
    @State private var role: MemberRole
    @State private var isActive: Bool
    
    init(member: TeamMember) {
        self.member = member
        _name = State(initialValue: member.name)
        _email = State(initialValue: member.email)
        _role = State(initialValue: member.role)
        _isActive = State(initialValue: member.isActive)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Role")) {
                    Picker("Role", selection: $role) {
                        ForEach(MemberRole.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                }
                
                Section(header: Text("Status")) {
                    Toggle("Active", isOn: $isActive)
                }
            }
            .navigationTitle("Edit Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppTheme.accentColor)
            )
        }
    }
    
    func saveChanges() {
        var updatedMember = member
        updatedMember.name = name
        updatedMember.email = email
        updatedMember.role = role
        updatedMember.isActive = isActive
        
        dataService.updateTeamMember(updatedMember)
        dismiss()
    }
}

