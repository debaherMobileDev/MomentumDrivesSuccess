//
//  TeamMember.swift
//  Momentum Drives Success
//

import Foundation

enum MemberRole: String, Codable, CaseIterable {
    case owner = "Owner"
    case manager = "Manager"
    case developer = "Developer"
    case designer = "Designer"
    case qa = "QA Engineer"
    case marketing = "Marketing"
    case other = "Other"
}

struct TeamMember: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var email: String
    var role: MemberRole
    var avatarColor: String
    var joinDate: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), name: String, email: String, role: MemberRole, avatarColor: String = "blue", joinDate: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor
        self.joinDate = joinDate
        self.isActive = isActive
    }
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}

