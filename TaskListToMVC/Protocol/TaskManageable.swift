//
//  TaskManageable.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/20.
//

import Foundation

// Task 管理相關協議
protocol TaskManageable {
    func getTasks(for date: Date) -> [Task]
    func getAllTasks() -> [Task]
    func addTask(_ task: Task)
    func updateTask(_ task: Task)
    func deleteTask(_ task: Task) throws
}
