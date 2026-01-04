//
//  ProjectDetailView.swift
//  Momentum Drives Success
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @ObservedObject var dataService = DataService.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var projectTasks: [Task] {
        dataService.getTasksForProject(project.id)
    }
    
    var teamMembers: [TeamMember] {
        project.teamMemberIds.compactMap { dataService.getTeamMember(byId: $0) }
    }
    
    var completedTasksCount: Int {
        projectTasks.filter { $0.status == .completed }.count
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(project.status.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor)
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Menu {
                                Button(action: { showingEditSheet = true }) {
                                    Label("Edit Project", systemImage: "pencil")
                                }
                                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                                    Label("Delete Project", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        
                        Text(project.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(project.description)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                        
                        // Progress
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(Int(project.progress * 100))%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.accentColor)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(AppTheme.accentColor)
                                        .frame(width: geometry.size.width * CGFloat(project.progress), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    
                    // Stats
                    HStack(spacing: 12) {
                        StatBox(title: "Tasks", value: "\(projectTasks.count)", color: .blue)
                        StatBox(title: "Completed", value: "\(completedTasksCount)", color: .green)
                        StatBox(title: "Team", value: "\(teamMembers.count)", color: .purple)
                    }
                    
                    // Details
                    VStack(spacing: 12) {
                        DetailRow(
                            icon: "calendar",
                            title: "Start Date",
                            value: project.startDate.formatted(date: .abbreviated, time: .omitted),
                            color: .green
                        )
                        
                        DetailRow(
                            icon: "flag.fill",
                            title: "Deadline",
                            value: project.deadline.formatted(date: .abbreviated, time: .omitted),
                            color: .red
                        )
                        
                        if let budget = project.budget {
                            DetailRow(
                                icon: "dollarsign.circle.fill",
                                title: "Budget",
                                value: String(format: "$%.0f", budget),
                                color: .yellow
                            )
                        }
                    }
                    
                    // Team Members
                    if !teamMembers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Team Members")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            ForEach(teamMembers) { member in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(member.avatarColor))
                                            .frame(width: 44, height: 44)
                                        
                                        Text(member.initials)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(member.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text(member.role.rawValue)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                            }
                        }
                    }
                    
                    // Tasks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tasks")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if projectTasks.isEmpty {
                            EmptyStateView(
                                icon: "checkmark.circle.fill",
                                title: "No Tasks Yet",
                                description: "Add tasks to this project to get started"
                            )
                        } else {
                            ForEach(projectTasks.sorted(by: { $0.deadline < $1.deadline })) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskRow(task: task)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditProjectView(project: project)
        }
        .alert("Delete Project", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataService.deleteProject(project)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this project? All associated tasks will also be deleted.")
        }
    }
    
    var statusColor: Color {
        switch project.status {
        case .planning: return .orange
        case .active: return .green
        case .onHold: return .yellow
        case .completed: return .blue
        case .archived: return .gray
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

struct EditProjectView: View {
    let project: Project
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var name: String
    @State private var description: String
    @State private var status: ProjectStatus
    @State private var progress: Double
    
    init(project: Project) {
        self.project = project
        _name = State(initialValue: project.name)
        _description = State(initialValue: project.description)
        _status = State(initialValue: project.status)
        _progress = State(initialValue: project.progress)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progress: \(Int(progress * 100))%")
                        Slider(value: $progress, in: 0...1, step: 0.05)
                    }
                }
            }
            .navigationTitle("Edit Project")
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
        var updatedProject = project
        updatedProject.name = name
        updatedProject.description = description
        updatedProject.status = status
        updatedProject.progress = progress
        
        if status == .completed && project.completedDate == nil {
            updatedProject.completedDate = Date()
        }
        
        dataService.updateProject(updatedProject)
        dismiss()
    }
}

