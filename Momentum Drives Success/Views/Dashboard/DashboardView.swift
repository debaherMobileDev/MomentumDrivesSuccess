//
//  DashboardView.swift
//  Momentum Drives Success
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var showingNewTask = false
    @State private var showingNewProject = false
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case overdue = "Overdue"
    }
    
    var filteredTasks: [Task] {
        let tasks = dataService.appData.tasks
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            return tasks.filter { $0.status != .completed }
        case .today:
            return tasks.filter {
                calendar.isDateInToday($0.deadline) && $0.status != .completed
            }
        case .thisWeek:
            return tasks.filter {
                calendar.isDate($0.deadline, equalTo: now, toGranularity: .weekOfYear) && $0.status != .completed
            }
        case .overdue:
            return tasks.filter {
                $0.deadline < now && $0.status != .completed
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats Cards
                        statsSection
                        
                        // Active Projects
                        projectsSection
                        
                        // Tasks Section
                        tasksSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingNewTask = true }) {
                            Label("New Task", systemImage: "plus.circle")
                        }
                        Button(action: { showingNewProject = true }) {
                            Label("New Project", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingNewTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showingNewProject) {
                AddProjectView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Active Tasks",
                value: "\(dataService.appData.tasks.filter { $0.status != .completed }.count)",
                icon: "checkmark.circle.fill",
                color: .blue
            )
            
            StatCard(
                title: "Projects",
                value: "\(dataService.appData.projects.filter { $0.status == .active }.count)",
                icon: "folder.fill",
                color: .green
            )
            
            StatCard(
                title: "Team",
                value: "\(dataService.appData.teamMembers.count)",
                icon: "person.3.fill",
                color: .purple
            )
        }
    }
    
    var projectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Projects")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: ProjectsListView()) {
                    Text("View All")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.accentColor)
                }
            }
            
            let activeProjects = dataService.appData.projects.filter { $0.status == .active }
            
            if activeProjects.isEmpty {
                EmptyStateView(
                    icon: "folder.fill",
                    title: "No Active Projects",
                    description: "Create your first project to get started"
                )
            } else {
                ForEach(activeProjects.prefix(3)) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        ProjectCard(project: project)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tasks")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
            }
            
            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            
            if filteredTasks.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle.fill",
                    title: "No Tasks",
                    description: "All clear! No tasks to show."
                )
            } else {
                ForEach(filteredTasks.sorted(by: { $0.deadline < $1.deadline })) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        TaskRow(task: task)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct ProjectCard: View {
    let project: Project
    @ObservedObject var dataService = DataService.shared
    
    var taskCount: Int {
        dataService.getTasksForProject(project.id).count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(project.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(taskCount) tasks")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(AppTheme.accentColor)
                        .frame(width: geometry.size.width * CGFloat(project.progress), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("\(Int(project.progress * 100))% complete")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                Spacer()
                
                Text("Due \(project.deadline.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct TaskRow: View {
    let task: Task
    @ObservedObject var dataService = DataService.shared
    
    var assignedMember: TeamMember? {
        if let assignedId = task.assignedToId {
            return dataService.getTeamMember(byId: assignedId)
        }
        return nil
    }
    
    var isOverdue: Bool {
        task.deadline < Date() && task.status != .completed
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack(spacing: 8) {
                    // Status Badge
                    Text(task.status.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor)
                        .cornerRadius(6)
                    
                    // Deadline
                    HStack(spacing: 4) {
                        Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                            .font(.system(size: 10))
                        Text(task.deadline.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12))
                    }
                    .foregroundColor(isOverdue ? .red : AppTheme.textSecondary)
                    
                    if let member = assignedMember {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10))
                            Text(member.name)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
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
    
    var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    var statusColor: Color {
        switch task.status {
        case .todo: return .gray
        case .inProgress: return .blue
        case .review: return .purple
        case .completed: return .green
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.accentColor : AppTheme.cardBackground)
                .cornerRadius(20)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

