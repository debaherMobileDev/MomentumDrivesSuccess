//
//  AppData.swift
//  Momentum Drives Success
//

import Foundation

struct AppData: Codable {
    var tasks: [Task]
    var projects: [Project]
    var teamMembers: [TeamMember]
    var messages: [Message]
    var currentUserId: UUID
    
    init(tasks: [Task] = [], projects: [Project] = [], teamMembers: [TeamMember] = [], messages: [Message] = [], currentUserId: UUID = UUID()) {
        self.tasks = tasks
        self.projects = projects
        self.teamMembers = teamMembers
        self.messages = messages
        self.currentUserId = currentUserId
    }
}

