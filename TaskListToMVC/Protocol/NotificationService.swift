//
//  NotificationService.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/20.
//

import Foundation
import UserNotifications


// 通知服務相關協議
protocol NotificationServiceProtocol {
    func schedule(for task: Task)
    func cancel(for task: Task)
}

// 通知服務實現
class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    
    private init() {}
    
    func schedule(for task: Task) {
        guard task.notificationEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "任務提醒"
        content.body = task.title
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancel(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
