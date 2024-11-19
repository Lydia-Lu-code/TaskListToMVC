//
//  TaskCell.swift
//  TaskListToMVC
//
//  Created by Lydia Lu on 2024/11/18.
//

import UIKit

class TaskCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let priorityLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Add subviews
        [titleLabel, statusLabel, priorityLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            priorityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priorityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        statusLabel.text = task.status.rawValue
        priorityLabel.text = task.priority.rawValue
        
        // Update appearance based on status
        switch task.status {
        case .completed:
            titleLabel.textColor = .gray
            titleLabel.attributedText = task.title.strikethrough()
        case .inProgress:
            titleLabel.textColor = .blue
            titleLabel.attributedText = nil
        case .todo:
            titleLabel.textColor = .black
            titleLabel.attributedText = nil
        }
        
        // Update priority label color
        switch task.priority {
        case .high:
            priorityLabel.textColor = .red
        case .medium:
            priorityLabel.textColor = .orange
        case .low:
            priorityLabel.textColor = .green
        }
    }
}
