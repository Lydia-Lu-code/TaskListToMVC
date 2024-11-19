//
//  TaskManager.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/18.
//

import Foundation

class TaskManager {
    static let shared = TaskManager()
    private var taskStorage: [String: [Task]] = [:]
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // CRUD operations
    func getTasks(for date: Date) -> [Task] {
        let key = dateFormatter.string(from: date)
        return taskStorage[key] ?? []
    }
    
    func addTask(_ task: Task) {
        let key = dateFormatter.string(from: task.dueDate)
        var tasks = taskStorage[key] ?? []
        tasks.append(task)
        taskStorage[key] = tasks
    }
    
    func updateTask(_ task: Task) {
        let key = dateFormatter.string(from: task.dueDate)
        if var tasks = taskStorage[key] {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
                taskStorage[key] = tasks
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        let key = dateFormatter.string(from: task.dueDate)
        if var tasks = taskStorage[key] {
            tasks.removeAll { $0.id == task.id }
            taskStorage[key] = tasks
        }
    }
}
