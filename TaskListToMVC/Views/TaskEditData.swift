
import Foundation
import UIKit

protocol TaskEditViewDelegate: AnyObject {
    func didTapSave(_ data: TaskEditData)
    func didTapCancel()
}

struct TaskEditData {
    let title: String
    let description: String?
    let dueDate: Date
    let status: TaskStatus
    let priority: TaskPriority
    let notificationEnabled: Bool
}

class TaskEditView: UIView {
    // MARK: - Properties
    weak var delegate: TaskEditViewDelegate?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "任務標題"
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let descriptionTextView: UITextView = {
        let view = UITextView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let dueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        return picker
    }()
    
    private let statusSegmentedControl = UISegmentedControl(items: ["待辦", "進行中", "完成"])
    private let prioritySegmentedControl = UISegmentedControl(items: ["低", "中", "高"])
    private let notificationSwitch = UISwitch()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(descriptionTextView)
        stackView.addArrangedSubview(dueDatePicker)
        stackView.addArrangedSubview(statusSegmentedControl)
        stackView.addArrangedSubview(prioritySegmentedControl)
        stackView.addArrangedSubview(createNotificationStack())
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
    
    // MARK: - Public Methods
    func configure(with task: Task) {
        titleTextField.text = task.title
        descriptionTextView.text = task.description
        dueDatePicker.date = task.dueDate
        statusSegmentedControl.selectedSegmentIndex = TaskStatus.allCases.firstIndex(of: task.status) ?? 0
        prioritySegmentedControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: task.priority) ?? 1
        notificationSwitch.isOn = task.notificationEnabled
    }
    
    func getTaskData() -> TaskEditData? {
        guard let title = titleTextField.text, !title.isEmpty,
              statusSegmentedControl.selectedSegmentIndex >= 0,
              prioritySegmentedControl.selectedSegmentIndex >= 0 else {
            return nil
        }
        
        return TaskEditData(
            title: title,
            description: descriptionTextView.text,
            dueDate: dueDatePicker.date,
            status: TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex],
            priority: TaskPriority.allCases[prioritySegmentedControl.selectedSegmentIndex],
            notificationEnabled: notificationSwitch.isOn
        )
    }
}
