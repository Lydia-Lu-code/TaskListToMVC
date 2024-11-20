
import Foundation

class TaskManager {
    static let shared = TaskManager()
    private var taskStorage: [String: [Task]] = [:]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private func normalizeDate(_ date: Date) -> Date {
        var calendar = Calendar.current
        // 使用 current 時區
        calendar.timeZone = TimeZone.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    init() {
        loadFromUserDefaults()
    }
    
    func getTasks(for date: Date) -> [Task] {
        let normalizedDate = normalizeDate(date)
        let key = dateFormatter.string(from: normalizedDate)
        let tasks = taskStorage[key] ?? []
        return tasks
    }
    
    func getAllTasks() -> [Task] {
        var allTasks: [Task] = []
        
        // 合併所有日期的任務
        for (_, tasks) in taskStorage {
            allTasks.append(contentsOf: tasks)
        }
        return allTasks
    }

    // 獲取所有存儲的日期
    func getAllDates() -> [Date] {
        return Array(taskStorage.keys).compactMap { dateFormatter.date(from: $0) }.sorted()
    }
    
    
    func addTask(_ task: Task) {
        let normalizedDate = normalizeDate(task.dueDate)
        let key = dateFormatter.string(from: normalizedDate)
        var tasks = taskStorage[key] ?? []
        tasks.append(task)
        taskStorage[key] = tasks
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(taskStorage)
            UserDefaults.standard.set(data, forKey: "tasks")
            UserDefaults.standard.synchronize()

            taskStorage.forEach { key, tasks in
                print("Key: \(key), Tasks count: \(tasks.count)")
            }
        } catch {
            print("Save error: \(error)")
        }
    }

    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: "tasks") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            taskStorage = try decoder.decode([String: [Task]].self, from: data)
        } catch {
            print("Load error: \(error)")
        }
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


