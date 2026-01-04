//
//  AddProjectView.swift
//  Momentum Drives Success
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataService = DataService.shared
    
    @State private var name = ""
    @State private var description = ""
    @State private var status: ProjectStatus = .planning
    @State private var startDate = Date()
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var budget: String = ""
    @State private var selectedMembers: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("Enter project name", text: $name)
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
                        
                        // Status
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            Picker("Status", selection: $status) {
                                ForEach(ProjectStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Dates
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Date")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deadline")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                        }
                        
                        // Budget
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Budget (Optional)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("$0", text: $budget)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(AppTheme.smallCornerRadius)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        // Team Members
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Team Members")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            ForEach(dataService.appData.teamMembers) { member in
                                Button(action: {
                                    if selectedMembers.contains(member.id) {
                                        selectedMembers.remove(member.id)
                                    } else {
                                        selectedMembers.insert(member.id)
                                    }
                                }) {
                                    HStack {
                                        // Avatar
                                        ZStack {
                                            Circle()
                                                .fill(Color(member.avatarColor))
                                                .frame(width: 40, height: 40)
                                            
                                            Text(member.initials)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(member.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppTheme.textPrimary)
                                            
                                            Text(member.role.rawValue)
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedMembers.contains(member.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedMembers.contains(member.id) ? AppTheme.accentColor : AppTheme.textSecondary)
                                    }
                                    .padding()
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(AppTheme.smallCornerRadius)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Create Button
                        Button(action: createProject) {
                            Text("Create Project")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(name.isEmpty ? Color.gray : AppTheme.accentColor)
                                .cornerRadius(AppTheme.cornerRadius)
                        }
                        .disabled(name.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Project")
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
    
    func createProject() {
        let budgetValue = Double(budget) ?? nil
        
        let newProject = Project(
            name: name,
            description: description,
            status: status,
            startDate: startDate,
            deadline: deadline,
            teamMemberIds: Array(selectedMembers),
            color: "blue",
            budget: budgetValue,
            progress: 0.0
        )
        
        dataService.addProject(newProject)
        dismiss()
    }
}

