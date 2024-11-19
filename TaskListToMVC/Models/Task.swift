//
//  Task.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/18.
//

import Foundation

struct Task: Codable {
    var id: UUID
    var title: String
    var description: String?
    var dueDate: Date
    var status: TaskStatus
    var priority: TaskPriority
    var notificationEnabled: Bool
    
    init(id: UUID = UUID(), title: String, description: String? = nil,
         dueDate: Date, status: TaskStatus = .todo,
         priority: TaskPriority = .medium, notificationEnabled: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.status = status
        self.priority = priority
        self.notificationEnabled = notificationEnabled
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "待辦"
    case inProgress = "進行中"
    case completed = "完成"
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "低"
    case medium = "中"
    case high = "高"
}

//enum TaskStatus: String, Codable {
//    case todo = "待辦"
//    case inProgress = "進行中"
//    case completed = "完成"
//}
//
//enum TaskPriority: String, Codable {
//    case low = "低"
//    case medium = "中"
//    case high = "高"
//}
