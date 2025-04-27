//
//  FriendRequestCell.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 4/27/25.
//

import UIKit

class FriendRequestCell: UITableViewCell {
    
    static let reuseIdentifier = "FriendRequestCell"
    
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    var confirmButton = UIButton(type: .system)
    var deleteButton = UIButton(type: .system)

    var onConfirm: (() -> Void)?
    var onDelete: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Configure Labels
        nameLabel.font = .boldSystemFont(ofSize: 16)
        usernameLabel.font = .systemFont(ofSize: 14)
        usernameLabel.textColor = .gray

        // Configure Confirm Button
        confirmButton.setTitle("  Confirm  ", for: .normal)
        confirmButton.backgroundColor = UIColor(red: 149/255, green: 154/255, blue: 133/255, alpha: 1.0)
        confirmButton.tintColor = .black
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        // Configure Delete Button
        deleteButton.setTitle("  Delete  ", for: .normal)
        deleteButton.backgroundColor = UIColor(red: 149/255, green: 154/255, blue: 133/255, alpha: 1.0)
        deleteButton.tintColor = .black
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.masksToBounds = true
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // Stack for Labels
        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2

        // Stack for Buttons
        let buttonsStack = UIStackView(arrangedSubviews: [confirmButton, deleteButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 8

        // Main Container Stack
        let container = UIStackView(arrangedSubviews: [labelsStack, UIView(), buttonsStack])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 16

        contentView.addSubview(container)
        contentView.backgroundColor = UIColor(red: 228/255, green: 235/255, blue: 203/255, alpha: 1.0)

        // Constraints
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func confirmTapped() {
        onConfirm?()
    }
    
    @objc private func deleteTapped() {
        onDelete?()
    }
}
