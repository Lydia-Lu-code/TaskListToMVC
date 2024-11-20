

import UIKit

class TaskCell: UITableViewCell {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateTimeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateTimeStack)
        dateTimeStack.addArrangedSubview(dateLabel)
        dateTimeStack.addArrangedSubview(timeLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(priorityLabel)
        containerView.addSubview(notificationImageView)
        
        // Setup constraints
        [containerView, titleLabel, dateTimeStack, statusLabel, priorityLabel, notificationImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Date Time Stack
            dateTimeStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateTimeStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dateTimeStack.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: dateTimeStack.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            statusLabel.widthAnchor.constraint(equalToConstant: 60),
            
            // Priority Label
            priorityLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor), // 修正這裡
            priorityLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 8),
            priorityLabel.widthAnchor.constraint(equalToConstant: 40),
            
            // Notification Image
            notificationImageView.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor), // 修正這裡
            notificationImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            notificationImageView.widthAnchor.constraint(equalToConstant: 20),
            notificationImageView.heightAnchor.constraint(equalToConstant: 20)

        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 清理所有文本和樣式
        titleLabel.text = nil
        titleLabel.attributedText = nil
        titleLabel.textColor = .black  // 重置為默認顏色
        
        dateLabel.text = nil
        timeLabel.text = nil
        
        statusLabel.text = nil
        statusLabel.backgroundColor = nil
        statusLabel.textColor = .black
        
        priorityLabel.text = nil
        priorityLabel.backgroundColor = nil
        priorityLabel.textColor = .black
        
        notificationImageView.image = nil
        containerView.backgroundColor = .systemBackground
    }
    
    func configure(with task: Task) {
         
         // Configure title
         switch task.status {
         case .completed:
             titleLabel.attributedText = task.title.strikethrough()
             titleLabel.textColor = .gray
             statusLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
             statusLabel.textColor = .systemGreen
         case .inProgress:
             titleLabel.attributedText = NSAttributedString(string: task.title)
             titleLabel.textColor = .black
             statusLabel.backgroundColor = .systemBlue.withAlphaComponent(0.2)
             statusLabel.textColor = .systemBlue
         case .todo:
             titleLabel.attributedText = NSAttributedString(string: task.title)
             titleLabel.textColor = .black
             statusLabel.backgroundColor = .systemGray.withAlphaComponent(0.2)
             statusLabel.textColor = .systemGray
         }
         
         // Configure status
         statusLabel.text = task.status.rawValue
         
         // Configure date and time
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy/MM/dd"
         dateLabel.text = dateFormatter.string(from: task.dueDate)
         
         dateFormatter.dateFormat = "HH:mm"
         timeLabel.text = dateFormatter.string(from: task.dueDate)
         
         // Configure priority
         priorityLabel.text = task.priority.rawValue
         switch task.priority {
         case .high:
             priorityLabel.backgroundColor = .systemRed.withAlphaComponent(0.2)
             priorityLabel.textColor = .systemRed
         case .medium:
             priorityLabel.backgroundColor = .systemOrange.withAlphaComponent(0.2)
             priorityLabel.textColor = .systemOrange
         case .low:
             priorityLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
             priorityLabel.textColor = .systemGreen
         }
         
         // Configure notification
         notificationImageView.image = task.notificationEnabled ?
             UIImage(systemName: "bell.fill") :
             UIImage(systemName: "bell.slash")
     }
    
}

