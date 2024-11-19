//
//  TaskEditViewController.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/18.
//

import UIKit

class TaskEditViewController: UIViewController {
    // MARK: - Properties
    private let stackView = UIStackView()
    private var titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "任務標題"
        field.borderStyle = .roundedRect
        return field
    }()
    
    private var descriptionTextView: UITextView = {
        let view = UITextView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 5
        return view
    }()
    
    private var dueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        return picker
    }()
    
    private var statusSegmentedControl = UISegmentedControl(items: ["待辦", "進行中", "完成"])
    private var prioritySegmentedControl = UISegmentedControl(items: ["低", "中", "高"])
    private var notificationSwitch = UISwitch()
    
    private var task: Task?
    weak var delegate: TaskEditDelegate?
    
    // MARK: - Lifecycle
    init(task: Task? = nil) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithTask()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        configureBasicUI()
        setupStackView()
        setupNavigationBar()
    }
    
    private func configureBasicUI() {
        view.backgroundColor = .white
        title = task == nil ? "新增任務" : "編輯任務"
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(descriptionTextView)
        stackView.addArrangedSubview(dueDatePicker)
        stackView.addArrangedSubview(statusSegmentedControl)
        stackView.addArrangedSubview(prioritySegmentedControl)
        stackView.addArrangedSubview(createNotificationStack())
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                         target: self,
                                                         action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                          target: self,
                                                          action: #selector(saveTapped))
    }
    
    private func createNotificationStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        
        let label = UILabel()
        label.text = "開啟提醒"
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(notificationSwitch)
        
        return stack
    }
    
    // MARK: - Task Configuration
    private func configureWithTask() {
        guard let task = task else { return }
        
        titleTextField.text = task.title
        descriptionTextView.text = task.description
        dueDatePicker.date = task.dueDate
        statusSegmentedControl.selectedSegmentIndex = TaskStatus.allCases.firstIndex(of: task.status) ?? 0
        prioritySegmentedControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: task.priority) ?? 1
        notificationSwitch.isOn = task.notificationEnabled
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "請輸入任務標題")
            return
        }
        
        let selectedStatusIndex = statusSegmentedControl.selectedSegmentIndex
        let selectedPriorityIndex = prioritySegmentedControl.selectedSegmentIndex
        
        guard selectedStatusIndex >= 0, selectedStatusIndex < TaskStatus.allCases.count,
              selectedPriorityIndex >= 0, selectedPriorityIndex < TaskPriority.allCases.count else {
            showAlert(message: "請選擇狀態和優先級")
            return
        }
        
        let newTask = Task(
            id: task?.id ?? UUID(),
            title: title,
            description: descriptionTextView.text,
            dueDate: dueDatePicker.date,
            status: TaskStatus.allCases[selectedStatusIndex],
            priority: TaskPriority.allCases[selectedPriorityIndex],
            notificationEnabled: notificationSwitch.isOn
        )
        
        task == nil ? delegate?.taskDidAdd(newTask) : delegate?.taskDidUpdate(newTask)
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
       let alert = UIAlertController(title: "錯誤",
                                   message: message,
                                   preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "確定", style: .default))
       present(alert, animated: true)
    }
}

extension String {
    func strikethrough() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }
}
