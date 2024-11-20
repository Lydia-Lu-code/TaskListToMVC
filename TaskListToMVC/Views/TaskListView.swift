

import Foundation
import UIKit

protocol TaskListViewDelegate: AnyObject {
    func didTapAddButton()
    func didSelectTask(_ task: Task)
    func didDeleteTask(_ task: Task)
    func didChangeDatePicker(to date: Date)
    func didPullToRefresh()
}

class TaskListView: UIView {
    // MARK: - Properties
    weak var delegate: TaskListViewDelegate?
    private var groupedTasks: [(date: Date, tasks: [Task])] = []
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
        table.delegate = self
        table.dataSource = self
        table.refreshControl = refreshControl
        return table
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        return button
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        
        let imageView = UIImageView(image: UIImage(systemName: "list.bullet.clipboard"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        
        let label = UILabel()
        label.text = "目前沒有任務\n點擊 + 新增任務"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.isHidden = true
        return view
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDatePicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(tableView)
        addSubview(addButton)
        addSubview(emptyStateView)
        
        [tableView, addButton, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            
            emptyStateView.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
        
        // 設置按鈕陰影效果
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 4
        addButton.layer.shadowOpacity = 0.2
    }
    
    private func setupDatePicker() {
        datePicker.addTarget(self, action: #selector(handleDateChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func handleAddButton() {
        delegate?.didTapAddButton()
    }
    
    @objc private func handleDateChanged() {
        delegate?.didChangeDatePicker(to: datePicker.date)
    }
    
    @objc private func handleRefresh() {
        delegate?.didPullToRefresh()
    }
    
    // MARK: - Public Methods
    func updateTasks(_ groupedTasks: [(date: Date, tasks: [Task])]) {
        self.groupedTasks = groupedTasks
        emptyStateView.isHidden = !groupedTasks.isEmpty
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension TaskListView: UITableViewDataSource, UITableViewDelegate {
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
        delegate?.didSelectTask(task)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = groupedTasks[indexPath.section].tasks[indexPath.row]
            delegate?.didDeleteTask(task)
        }
    }
}

