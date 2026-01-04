//
//  Task.swift
//  Momentum Drives Success
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case review = "In Review"
    case completed = "Completed"
    
    var color: String {
        switch self {
        case .todo: return "gray"
        case .inProgress: return "blue"
        case .review: return "purple"
        case .completed: return "green"
        }
    }
}

struct Task: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var priority: TaskPriority
    var status: TaskStatus
    var deadline: Date
    var createdDate: Date
    var completedDate: Date?
    var assignedToId: UUID?
    var projectId: UUID?
    var tags: [String]
    var estimatedHours: Double
    var actualHours: Double
    
    init(id: UUID = UUID(), title: String, description: String, priority: TaskPriority = .medium, status: TaskStatus = .todo, deadline: Date, createdDate: Date = Date(), completedDate: Date? = nil, assignedToId: UUID? = nil, projectId: UUID? = nil, tags: [String] = [], estimatedHours: Double = 0, actualHours: Double = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.deadline = deadline
        self.createdDate = createdDate
        self.completedDate = completedDate
        self.assignedToId = assignedToId
        self.projectId = projectId
        self.tags = tags
        self.estimatedHours = estimatedHours
        self.actualHours = actualHours
    }
}

