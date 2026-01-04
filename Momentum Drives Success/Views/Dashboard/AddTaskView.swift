//
//  AddTaskView.swift
//  Momentum Drives Success
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var status: TaskStatus = .todo
    @State private var deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var selectedProject: Project?
    @State private var selectedMember: TeamMember?
    @State private var estimatedHours: Double = 8
    @State private var tags: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("Enter task title", text: $title)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(8)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Priority", selection: $priority) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Text(priority.rawValue).tag(priority)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Status
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Status", selection: $status) {
                                ForEach(TaskStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Deadline
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deadline")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Project
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
                        
                        // Assign to
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assign to (Optional)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Assign to", selection: $selectedMember) {
                                Text("Unassigned").tag(nil as TeamMember?)
                                ForEach(dataService.appData.teamMembers, id: \.self) { member in
                                    Text(member.name).tag(member as TeamMember?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Estimated Hours
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estimated Hours: \(Int(estimatedHours))h")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Slider(value: $estimatedHours, in: 1...40, step: 1)
                                .accentColor(AppTheme.accentColor)
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags (comma separated)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("design, frontend, urgent", text: $tags)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Create Button
                        Button(action: createTask) {
                            Text("Create Task")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(title.isEmpty ? Color.gray : AppTheme.accentColor)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .disabled(title.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Task")
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
    
    func createTask() {
        let tagArray = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        let newTask = Task(
            title: title,
            description: description,
            priority: priority,
            status: status,
            deadline: deadline,
            assignedToId: selectedMember?.id,
            projectId: selectedProject?.id,
            tags: tagArray,
            estimatedHours: estimatedHours,
            actualHours: 0
        )
        
        dataService.addTask(newTask)
        dismiss()
    }
}

