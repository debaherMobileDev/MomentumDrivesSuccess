//
//  AnalyticsView.swift
//  Momentum Drives Success
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var selectedPeriod: TimePeriod = .week
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period Selector
                        periodSelector
                        
                        // Key Metrics
                        keyMetrics
                        
                        // Task Completion Chart
                        taskCompletionChart
                        
                        // Priority Distribution
                        priorityDistribution
                        
                        // Team Performance
                        teamPerformance
                        
                        // Project Progress
                        projectProgress
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var periodSelector: some View {
        HStack(spacing: 12) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: { selectedPeriod = period }) {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedPeriod == period ? AppTheme.accentColor : AppTheme.cardBackground)
                        .cornerRadius(AppTheme.smallCornerRadius)
                }
            }
        }
    }
    
    var keyMetrics: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(
                    title: "Completion Rate",
                    value: "\(completionRate)%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                MetricCard(
                    title: "Total Tasks",
                    value: "\(totalTasks)",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )
            }
            
            HStack(spacing: 12) {
                MetricCard(
                    title: "Hours Logged",
                    value: "\(Int(totalHours))h",
                    icon: "clock.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Active Projects",
                    value: "\(activeProjects)",
                    icon: "folder.fill",
                    color: .purple
                )
            }
        }
    }
    
    var taskCompletionChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Completion Trend")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 12) {
                SimpleLineChart(data: getChartData().map { Double($0.completed) })
                    .frame(height: 200)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
    
    var priorityDistribution: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Priority Distribution")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(getPriorityData()) { data in
                    HStack(spacing: 12) {
                        Text(data.priority)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(data.color)
                                    .frame(width: CGFloat(data.count) * (geometry.size.width / 10), height: 24)
                                    .cornerRadius(4)
                                
                                Spacer()
                            }
                        }
                        .frame(height: 24)
                        
                        Text("\(data.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 30)
                    }
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
    }
    
    var teamPerformance: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Performance")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(getTeamPerformanceData()) { data in
                VStack(spacing: 8) {
                    HStack {
                        Text(data.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Text("\(data.completed)/\(data.total)")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(AppTheme.accentColor)
                                .frame(width: geometry.size.width * data.percentage, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
    }
    
    var projectProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Project Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ForEach(dataService.appData.projects.filter { $0.status == .active }) { project in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(project.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Text("\(Int(project.progress * 100))%")
                            .font(.system(size: 14, weight: .bold))
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
                    
                    Text("Due \(project.deadline.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var completionRate: Int {
        let total = dataService.appData.tasks.count
        guard total > 0 else { return 0 }
        let completed = dataService.appData.tasks.filter { $0.status == .completed }.count
        return Int((Double(completed) / Double(total)) * 100)
    }
    
    var totalTasks: Int {
        dataService.appData.tasks.count
    }
    
    var totalHours: Double {
        dataService.appData.tasks.reduce(0) { $0 + $1.actualHours }
    }
    
    var activeProjects: Int {
        dataService.appData.projects.filter { $0.status == .active }.count
    }
    
    // MARK: - Helper Methods
    
    func getChartData() -> [ChartData] {
        let calendar = Calendar.current
        let now = Date()
        var data: [ChartData] = []
        
        let daysCount = selectedPeriod == .week ? 7 : (selectedPeriod == .month ? 30 : 365)
        
        for i in 0..<min(daysCount, 7) {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            let completed = dataService.appData.tasks.filter { task in
                guard let completedDate = task.completedDate else { return false }
                return calendar.isDate(completedDate, inSameDayAs: date)
            }.count
            
            data.append(ChartData(
                id: UUID(),
                day: calendar.component(.day, from: date),
                completed: completed
            ))
        }
        
        return data.reversed()
    }
    
    func getPriorityData() -> [PriorityData] {
        let tasks = dataService.appData.tasks.filter { $0.status != .completed }
        
        return TaskPriority.allCases.map { priority in
            let count = tasks.filter { $0.priority == priority }.count
            let color: Color = {
                switch priority {
                case .low: return .green
                case .medium: return .yellow
                case .high: return .orange
                case .critical: return .red
                }
            }()
            
            return PriorityData(id: UUID(), priority: priority.rawValue, count: count, color: color)
        }
    }
    
    func getTeamPerformanceData() -> [TeamPerformanceData] {
        return dataService.appData.teamMembers.map { member in
            let memberTasks = dataService.appData.tasks.filter { $0.assignedToId == member.id }
            let total = memberTasks.count
            let completed = memberTasks.filter { $0.status == .completed }.count
            let percentage = total > 0 ? CGFloat(completed) / CGFloat(total) : 0
            
            return TeamPerformanceData(
                id: member.id,
                name: member.name,
                completed: completed,
                total: total,
                percentage: percentage
            )
        }.filter { $0.total > 0 }
    }
}

struct ChartData: Identifiable {
    let id: UUID
    let day: Int
    let completed: Int
}

struct PriorityData: Identifiable {
    let id: UUID
    let priority: String
    let count: Int
    let color: Color
}

struct TeamPerformanceData: Identifiable {
    let id: UUID
    let name: String
    let completed: Int
    let total: Int
    let percentage: CGFloat
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

// Simple line chart for iOS 15.6 compatibility
struct SimpleLineChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
            let stepY = geometry.size.height / CGFloat(maxValue == 0 ? 1 : maxValue)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { _ in
                        Divider()
                            .background(AppTheme.textSecondary.opacity(0.2))
                        Spacer()
                    }
                }
                
                // Line path
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - (CGFloat(value) * stepY)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(AppTheme.accentColor, lineWidth: 3)
                
                // Area under line
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - (CGFloat(value) * stepY)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: CGFloat(data.count - 1) * stepX, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(AppTheme.accentColor.opacity(0.2))
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    Circle()
                        .fill(AppTheme.accentColor)
                        .frame(width: 8, height: 8)
                        .position(
                            x: CGFloat(index) * stepX,
                            y: geometry.size.height - (CGFloat(value) * stepY)
                        )
                }
            }
        }
    }
}

