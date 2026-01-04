//
//  ProjectsListView.swift
//  Momentum Drives Success
//

import SwiftUI

struct ProjectsListView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var showingNewProject = false
    @State private var selectedFilter: ProjectStatus?
    
    var filteredProjects: [Project] {
        if let filter = selectedFilter {
            return dataService.appData.projects.filter { $0.status == filter }
        }
        return dataService.appData.projects
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "All", isSelected: selectedFilter == nil) {
                                selectedFilter = nil
                            }
                            
                            ForEach(ProjectStatus.allCases, id: \.self) { status in
                                FilterChip(title: status.rawValue, isSelected: selectedFilter == status) {
                                    selectedFilter = status
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Projects
                    if filteredProjects.isEmpty {
                        EmptyStateView(
                            icon: "folder.fill",
                            title: "No Projects",
                            description: "Create your first project to get started"
                        )
                        .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredProjects) { project in
                                NavigationLink(destination: ProjectDetailView(project: project)) {
                                    ProjectCard(project: project)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingNewProject = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingNewProject) {
            AddProjectView()
        }
    }
}

