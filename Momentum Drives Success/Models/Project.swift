//
//  Project.swift
//  Momentum Drives Success
//

import Foundation

enum ProjectStatus: String, Codable, CaseIterable {
    case planning = "Planning"
    case active = "Active"
    case onHold = "On Hold"
    case completed = "Completed"
    case archived = "Archived"
}

struct Project: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var status: ProjectStatus
    var startDate: Date
    var deadline: Date
    var completedDate: Date?
    var teamMemberIds: [UUID]
    var color: String
    var budget: Double?
    var progress: Double // 0.0 to 1.0
    
    init(id: UUID = UUID(), name: String, description: String, status: ProjectStatus = .planning, startDate: Date = Date(), deadline: Date, completedDate: Date? = nil, teamMemberIds: [UUID] = [], color: String = "blue", budget: Double? = nil, progress: Double = 0.0) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.startDate = startDate
        self.deadline = deadline
        self.completedDate = completedDate
        self.teamMemberIds = teamMemberIds
        self.color = color
        self.budget = budget
        self.progress = progress
    }
}

