//
//  TaskEditDelegate.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/18.
//

import Foundation

protocol TaskEditDelegate: AnyObject {
    func taskDidAdd(_ task: Task)
    func taskDidUpdate(_ task: Task)
}
