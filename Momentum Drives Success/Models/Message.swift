//
//  Message.swift
//  Momentum Drives Success
//

import Foundation

struct Message: Identifiable, Codable, Hashable {
    var id: UUID
    var senderId: UUID
    var recipientId: UUID?
    var projectId: UUID?
    var content: String
    var timestamp: Date
    var isRead: Bool
    
    init(id: UUID = UUID(), senderId: UUID, recipientId: UUID? = nil, projectId: UUID? = nil, content: String, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.senderId = senderId
        self.recipientId = recipientId
        self.projectId = projectId
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

