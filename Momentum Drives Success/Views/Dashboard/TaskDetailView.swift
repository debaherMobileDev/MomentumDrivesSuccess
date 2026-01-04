//
//  TaskDetailView.swift
//  Momentum Drives Success
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var dataService = DataService.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var assignedMember: TeamMember? {
        if let assignedId = task.assignedToId {
            return dataService.getTeamMember(byId: assignedId)
        }
        return nil
    }
    
    var project: Project? {
        if let projectId = task.projectId {
            return dataService.getProject(byId: projectId)
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(priorityColor)
                                .frame(width: 12, height: 12)
                            
                            Text(task.priority.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(priorityColor)
                            
                            Spacer()
                            
                            Text(task.status.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor)
                                .cornerRadius(8)
                        }
                        
                        Text(task.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(task.description)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    
                    // Details
                    VStack(spacing: 16) {
                        DetailRow(
                            icon: "calendar",
                            title: "Deadline",
                            value: task.deadline.formatted(date: .long, time: .omitted),
                            color: isOverdue ? .red : .blue
                        )
                        
                        if let project = project {
                            DetailRow(
                                icon: "folder.fill",
                                title: "Project",
                                value: project.name,
                                color: .purple
                            )
                        }
                        
                        if let member = assignedMember {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 24)
                                
                                Text("Assigned to")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(member.avatarColor))
                                            .frame(width: 28, height: 28)
                                        
                                        Text(member.initials)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(member.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        DetailRow(
                            icon: "clock.fill",
                            title: "Estimated Hours",
                            value: "\(Int(task.estimatedHours))h",
                            color: .orange
                        )
                        
                        DetailRow(
                            icon: "chart.bar.fill",
                            title: "Actual Hours",
                            value: "\(Int(task.actualHours))h",
                            color: .yellow
                        )
                        
                        if !task.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(AppTheme.accentColor)
                                        .frame(width: 24)
                                    
                                    Text("Tags")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                WrappingHStack(items: task.tags) { tag in
                                    Text(tag)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.accentColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.accentColor.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { showingEditSheet = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Task")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.accentColor)
                            .cornerRadius(AppTheme.cornerRadius)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Task")
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
                .padding()
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditTaskView(task: task)
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataService.deleteTask(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
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
    
    var isOverdue: Bool {
        task.deadline < Date() && task.status != .completed
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.smallCornerRadius)
    }
}

// Simple wrapping HStack for iOS 15.6 compatibility
struct WrappingHStack<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                content(item)
                    .padding(.all, 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if index == items.count - 1 {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if index == items.count - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct EditTaskView: View {
    let task: Task
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var deadline: Date
    @State private var actualHours: Double
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _priority = State(initialValue: task.priority)
        _status = State(initialValue: task.status)
        _deadline = State(initialValue: task.deadline)
        _actualHours = State(initialValue: task.actualHours)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Status")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section(header: Text("Timing")) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Actual Hours: \(Int(actualHours))h")
                        Slider(value: $actualHours, in: 0...80, step: 1)
                    }
                }
            }
            .navigationTitle("Edit Task")
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
        var updatedTask = task
        updatedTask.title = title
        updatedTask.description = description
        updatedTask.priority = priority
        updatedTask.status = status
        updatedTask.deadline = deadline
        updatedTask.actualHours = actualHours
        
        if status == .completed && task.completedDate == nil {
            updatedTask.completedDate = Date()
        }
        
        dataService.updateTask(updatedTask)
        dismiss()
    }
}

