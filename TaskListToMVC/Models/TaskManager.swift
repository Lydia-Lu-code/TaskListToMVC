
// (業務邏輯)

import Foundation

class TaskManager {
    static let shared = TaskManager()
    private var taskStorage: [String: [Task]] = [:]
    private let dataManager: DataManagerProtocol
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // 修正初始化方法
    private init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager // 先初始化 dataManager
        loadFromStorage() // 然後載入資料
    }
    
    private func loadFromStorage() {
        do {
            self.taskStorage = try dataManager.load(forKey: "tasks")
        } catch DataManagerError.dataNotFound {
            self.taskStorage = [:] // 如果沒有資料，使用空字典
        } catch {
            print("Load error: \(error)")
            self.taskStorage = [:]
        }
    }
    
    func getTasks(for date: Date) -> [Task] {
        let normalizedDate = normalizeDate(date)
        let key = dateFormatter.string(from: normalizedDate)
        return taskStorage[key] ?? []
    }
    
    func getAllTasks() -> [Task] {
        return taskStorage.values.flatMap { $0 }
    }
    
    // 獲取所有存儲的日期
    func getAllDates() -> [Date] {
        return Array(taskStorage.keys)
            .compactMap { dateFormatter.date(from: $0) }
            .sorted()
    }
    
    func addTask(_ task: Task) {
        let normalizedDate = normalizeDate(task.dueDate)
        let key = dateFormatter.string(from: normalizedDate)
        var tasks = taskStorage[key] ?? []
        tasks.append(task)
        taskStorage[key] = tasks
        
        try? saveToStorage()
    }
    
    func updateTask(_ task: Task) {
        let key = dateFormatter.string(from: task.dueDate)
        if var tasks = taskStorage[key],
           let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            taskStorage[key] = tasks
            try? saveToStorage()
        }
    }
    
    func deleteTask(_ task: Task) throws {
        print("TaskManager - 開始刪除任務")
        let key = dateFormatter.string(from: task.dueDate)
        print("要刪除的日期 key: \(key)")
        
        if var tasks = taskStorage[key] {
            print("該日期原有任務數: \(tasks.count)")
            tasks.removeAll { $0.id == task.id }
            print("刪除後剩餘任務數: \(tasks.count)")
            
            if tasks.isEmpty {
                taskStorage.removeValue(forKey: key)
                print("日期 \(key) 已無任務，移除該 key")
            } else {
                taskStorage[key] = tasks
                print("更新該日期的任務列表")
            }
            
            try saveToStorage()
            print("變更已保存到 storage")
            
            // 印出當前所有資料
            print("\n當前 storage 狀態:")
            taskStorage.forEach { (key, tasks) in
                print("日期 \(key): \(tasks.count) 個任務")
                tasks.forEach { task in
                    print("- \(task.title)")
                }
            }
        } else {
            print("找不到該日期的任務資料")
        }
    }
    
    
    private func normalizeDate(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    private func saveToStorage() throws {
        try dataManager.save(taskStorage, forKey: "tasks")
    }
}


