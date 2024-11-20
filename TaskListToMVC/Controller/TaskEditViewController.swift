import UIKit

class TaskEditViewController: UIViewController {
    // MARK: - Properties
    private let mainView = TaskEditView()
    private var task: Task?
    weak var delegate: TaskEditDelegate?
    
    // MARK: - Initialization
    init(task: Task? = nil) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        mainView.delegate = self
        
        if let task = task {
            mainView.configure(with: task)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = task == nil ? "新增任務" : "編輯任務"
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "錯誤",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let taskData = mainView.getTaskData() else {
            showAlert(message: "請輸入必要資訊")
            return
        }
        
        let newTask = Task(
            id: task?.id ?? UUID(),
            title: taskData.title,
            description: taskData.description,
            dueDate: taskData.dueDate,
            status: taskData.status,
            priority: taskData.priority,
            notificationEnabled: taskData.notificationEnabled
        )
        
        task == nil ? delegate?.taskDidAdd(newTask) : delegate?.taskDidUpdate(newTask)
        dismiss(animated: true)
    }
}

// MARK: - TaskEditViewDelegate
extension TaskEditViewController: TaskEditViewDelegate {
    func didTapSave(_ data: TaskEditData) {
        saveTapped()
    }
    
    func didTapCancel() {
        cancelTapped()
    }
}

