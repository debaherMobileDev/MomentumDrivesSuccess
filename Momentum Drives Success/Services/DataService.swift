//
//  DataService.swift
//  Momentum Drives Success
//

import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var appData: AppData
    
    private let appDataKey = "MomentumDrivesSuccess_AppData"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: appDataKey),
           let decoded = try? JSONDecoder().decode(AppData.self, from: data) {
            self.appData = decoded
        } else {
            // Initialize with sample data
            self.appData = DataService.createSampleData()
            self.save()
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(appData) {
            UserDefaults.standard.set(encoded, forKey: appDataKey)
        }
    }
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: appDataKey)
        self.appData = DataService.createSampleData()
        self.save()
    }
    
    // MARK: - Task Operations
    func addTask(_ task: Task) {
        appData.tasks.append(task)
        save()
    }
    
    func updateTask(_ task: Task) {
        if let index = appData.tasks.firstIndex(where: { $0.id == task.id }) {
            appData.tasks[index] = task
            save()
        }
    }
    
    func deleteTask(_ task: Task) {
        appData.tasks.removeAll { $0.id == task.id }
        save()
    }
    
    // MARK: - Project Operations
    func addProject(_ project: Project) {
        appData.projects.append(project)
        save()
    }
    
    func updateProject(_ project: Project) {
        if let index = appData.projects.firstIndex(where: { $0.id == project.id }) {
            appData.projects[index] = project
            save()
        }
    }
    
    func deleteProject(_ project: Project) {
        appData.projects.removeAll { $0.id == project.id }
        appData.tasks.removeAll { $0.projectId == project.id }
        save()
    }
    
    // MARK: - Team Member Operations
    func addTeamMember(_ member: TeamMember) {
        appData.teamMembers.append(member)
        save()
    }
    
    func updateTeamMember(_ member: TeamMember) {
        if let index = appData.teamMembers.firstIndex(where: { $0.id == member.id }) {
            appData.teamMembers[index] = member
            save()
        }
    }
    
    func deleteTeamMember(_ member: TeamMember) {
        appData.teamMembers.removeAll { $0.id == member.id }
        save()
    }
    
    // MARK: - Message Operations
    func addMessage(_ message: Message) {
        appData.messages.append(message)
        save()
    }
    
    func markMessageAsRead(_ messageId: UUID) {
        if let index = appData.messages.firstIndex(where: { $0.id == messageId }) {
            appData.messages[index].isRead = true
            save()
        }
    }
    
    // MARK: - Helper Methods
    func getTasksForProject(_ projectId: UUID) -> [Task] {
        return appData.tasks.filter { $0.projectId == projectId }
    }
    
    func getTeamMember(byId id: UUID) -> TeamMember? {
        return appData.teamMembers.first { $0.id == id }
    }
    
    func getProject(byId id: UUID) -> Project? {
        return appData.projects.first { $0.id == id }
    }
    
    func getUnreadMessageCount() -> Int {
        return appData.messages.filter { !$0.isRead }.count
    }
    
    // MARK: - Sample Data
    static func createSampleData() -> AppData {
        let currentUser = TeamMember(
            name: "You",
            email: "you@company.com",
            role: .owner,
            avatarColor: "pink"
        )
        
        let member1 = TeamMember(
            name: "Sarah Johnson",
            email: "sarah@company.com",
            role: .manager,
            avatarColor: "blue"
        )
        
        let member2 = TeamMember(
            name: "Michael Chen",
            email: "michael@company.com",
            role: .developer,
            avatarColor: "green"
        )
        
        let member3 = TeamMember(
            name: "Emma Williams",
            email: "emma@company.com",
            role: .designer,
            avatarColor: "purple"
        )
        
        let project1 = Project(
            name: "Mobile App Launch",
            description: "Launch the new mobile application for our platform",
            status: .active,
            startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            deadline: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            teamMemberIds: [currentUser.id, member1.id, member2.id],
            color: "blue",
            budget: 50000,
            progress: 0.65
        )
        
        let project2 = Project(
            name: "Website Redesign",
            description: "Complete redesign of the company website",
            status: .planning,
            startDate: Date(),
            deadline: Calendar.current.date(byAdding: .day, value: 60, to: Date())!,
            teamMemberIds: [currentUser.id, member3.id],
            color: "purple",
            budget: 30000,
            progress: 0.15
        )
        
        let task1 = Task(
            title: "Design new UI mockups",
            description: "Create high-fidelity mockups for the main dashboard",
            priority: .high,
            status: .inProgress,
            deadline: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            assignedToId: member3.id,
            projectId: project1.id,
            tags: ["design", "ui"],
            estimatedHours: 16,
            actualHours: 8
        )
        
        let task2 = Task(
            title: "Implement authentication",
            description: "Add OAuth2 authentication to the backend",
            priority: .critical,
            status: .todo,
            deadline: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            assignedToId: member2.id,
            projectId: project1.id,
            tags: ["backend", "security"],
            estimatedHours: 24,
            actualHours: 0
        )
        
        let task3 = Task(
            title: "Write project documentation",
            description: "Document the API endpoints and usage",
            priority: .medium,
            status: .review,
            deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            assignedToId: currentUser.id,
            projectId: project1.id,
            tags: ["documentation"],
            estimatedHours: 8,
            actualHours: 6
        )
        
        let task4 = Task(
            title: "Research competitor websites",
            description: "Analyze top 10 competitor websites for inspiration",
            priority: .low,
            status: .completed,
            deadline: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            completedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            assignedToId: member1.id,
            projectId: project2.id,
            tags: ["research"],
            estimatedHours: 4,
            actualHours: 5
        )
        
        let message1 = Message(
            senderId: member1.id,
            recipientId: currentUser.id,
            projectId: project1.id,
            content: "Can we schedule a meeting to discuss the project timeline?",
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
            isRead: false
        )
        
        let message2 = Message(
            senderId: member2.id,
            recipientId: currentUser.id,
            content: "I've completed the database migration. Ready for review.",
            timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
            isRead: true
        )
        
        return AppData(
            tasks: [task1, task2, task3, task4],
            projects: [project1, project2],
            teamMembers: [currentUser, member1, member2, member3],
            messages: [message1, message2],
            currentUserId: currentUser.id
        )
    }
}

