
import UIKit

class TaskListViewController: UIViewController {
    // MARK: - Properties
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    private var groupedTasks: [(date: Date, tasks: [Task])] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    
    private var tasks: [Task] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped) // 使用分組樣式提高視覺效果

        table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.separatorStyle = .none // 因為我們使用自定義 cell 的卡片樣式
        table.backgroundColor = .systemGroupedBackground
        table.showsVerticalScrollIndicator = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()


    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        return button
    }()
    
    // 新增日期選擇器
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    private var selectedDate: Date = Date() {
        didSet {
            loadTasks()
        }
    }
    
    init() {
        let calendar = Calendar.current
        self.selectedDate = calendar.startOfDay(for: Date())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.selectedDate = Calendar.current.startOfDay(for: Date())
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks() // 每次視圖出現時重新加載任務
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
         
        setupUI()
        setupTableView()
        setupNotifications()
         
        selectedDate = normalizeDate(Date())
        loadTasks()
        

    }
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // 修改日期選擇器的行為
    @objc private func dateChanged() {
        let selectedDate = datePicker.date
        // 可以選擇性地滾動到選定日期的部分
        if let sectionIndex = groupedTasks.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            let indexPath = IndexPath(row: 0, section: sectionIndex)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "任務清單"
        
        // 添加日期選擇器到導航欄
        let dateItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateItem
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        
        // TableView setup
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        
        // Add Button setup
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current  // 使用當前時區
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func loadTasks() {
        
        // 獲取所有任務
        let allTasks = TaskManager.shared.getAllTasks()
        
        // 按日期分組
        let calendar = Calendar.current
        var groupedDict: [Date: [Task]] = [:]
        
        allTasks.forEach { task in
            let startOfDay = calendar.startOfDay(for: task.dueDate)
            if groupedDict[startOfDay] == nil {
                groupedDict[startOfDay] = []
            }
            groupedDict[startOfDay]?.append(task)
        }
        
        // 將分組的任務轉換為數組並排序
        groupedTasks = groupedDict.map { (date: $0.key, tasks: $0.value) }
            .sorted { $0.date < $1.date }
        
        // 對每個組內的任務按時間排序
        groupedTasks = groupedTasks.map { (date, tasks) in
            let sortedTasks = tasks.sorted { $0.dueDate < $1.dueDate }
            return (date: date, tasks: sortedTasks)
        }
        
        groupedTasks.forEach { section in
            section.tasks.forEach { task in
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    

    
    private func scheduleNotification(for task: Task) {
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
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let taskEditVC = TaskEditViewController()
        taskEditVC.delegate = self  // 設置 delegate
        let nav = UINavigationController(rootViewController: taskEditVC)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedTasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedTasks[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = groupedTasks[indexPath.section].tasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = groupedTasks[section].date
        return dateFormatter.string(from: date)
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .darkGray
        dateLabel.text = dateFormatter.string(from: groupedTasks[section].date)
        
        let taskCountLabel = UILabel()
        taskCountLabel.font = .systemFont(ofSize: 14)
        taskCountLabel.textColor = .gray
        taskCountLabel.text = "(\(groupedTasks[section].tasks.count)個任務)"
        
        let stackView = UIStackView(arrangedSubviews: [dateLabel, taskCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = groupedTasks[indexPath.section].tasks[indexPath.row]
        let taskEditVC = TaskEditViewController(task: task)
        taskEditVC.delegate = self
        let nav = UINavigationController(rootViewController: taskEditVC)
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = groupedTasks[indexPath.section].tasks[indexPath.row]
            do {
                print("開始刪除任務: \(task.title)")
                
                // 1. 先從 TaskManager 刪除數據
                try TaskManager.shared.deleteTask(task)
                print("TaskManager 刪除成功")
                
                // 2. 更新本地數據結構
                var sectionTasks = groupedTasks[indexPath.section].tasks
                sectionTasks.remove(at: indexPath.row)
                
                if sectionTasks.isEmpty {
                    groupedTasks.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    print("刪除整個 section")
                } else {
                    groupedTasks[indexPath.section].tasks = sectionTasks
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    print("刪除單個任務")
                }
                
                // 3. 移除通知
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
                print("通知已移除")
                
                // 4. 檢查當前資料狀態
                let remainingTasks = TaskManager.shared.getAllTasks()
                print("剩餘任務數量: \(remainingTasks.count)")
                remainingTasks.forEach { task in
                    print("- \(task.title)")
                }
                
            } catch {
                print("刪除失敗: \(error.localizedDescription)")
            }
        }
    }

}

// MARK: - TaskEditDelegate
extension TaskListViewController: TaskEditDelegate {
    func taskDidAdd(_ task: Task) {
        TaskManager.shared.addTask(task)
        loadTasks()
        scheduleNotification(for: task)
    }
    
    func taskDidUpdate(_ task: Task) {
        TaskManager.shared.updateTask(task)
        loadTasks()
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        scheduleNotification(for: task)
    }
}

extension String {
    func strikethrough() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.gray
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}

