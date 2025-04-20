//
//  AddFriendViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/19/25.
//

import UIKit


// MARK: - Model
struct FriendRequest {
    let displayName: String
    let username: String
}

// MARK: - Cell
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

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        nameLabel.font = .boldSystemFont(ofSize: 16)
        usernameLabel.font = .systemFont(ofSize: 14)
        usernameLabel.textColor = .gray
        
//        let padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        confirmButton.setTitle("  Confirm  ", for: .normal)
//        confirmButton..width = padding
        confirmButton.backgroundColor = UIColor(red: 149.0/255.0, green: 154.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        confirmButton.tintColor = .black
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.masksToBounds = true

        deleteButton.setTitle("  Delete  ", for: .normal)
//        deleteButton.contentEdgeInsets = padding
        // — give it the same look as Confirm:
        deleteButton.backgroundColor = UIColor(red: 149.0/255.0, green: 154.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        deleteButton.tintColor = .black
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.masksToBounds = true

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, usernameLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2

        let buttonsStack = UIStackView(arrangedSubviews: [confirmButton, deleteButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 8

        let container = UIStackView(arrangedSubviews: [labelsStack, UIView(), buttonsStack])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 16

        contentView.addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 228.0/255.0, green: 235.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        contentView.backgroundColor = UIColor(red: 228.0/255.0, green: 235.0/255.0, blue: 203.0/255.0, alpha: 1.0)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    @objc private func confirmTapped() { onConfirm?() }
    @objc private func deleteTapped()  { onDelete?() }
}

// MARK: - View Controller
class AddFriendViewController: UIViewController {
    
    var currentUser: User?

    @IBOutlet weak var homeButton: UIImageView!
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var requests: [FriendRequest] = [
        .init(displayName: "Courtney Johnson", username: "@CourtneyJohnson"),
        .init(displayName: "Stephanie Nguyen",  username: "@StephanieNguyen"),
        .init(displayName: "Lauren Leyendecker",  username: "@LaurenLeyendecker"),
        .init(displayName: "Jafrina Rahman",  username: "@JafrinaRahman")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Friend Requests"
        view.backgroundColor = UIColor(red: 228.0/255.0, green: 235.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        navigationItem.backButtonTitle = "Back"
       
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: FriendRequestCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 228.0/255.0, green: 235.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let homeScreenGesture = UITapGestureRecognizer(target: self, action: #selector(homeBackImageTapped(_:)))
        
        homeButton.addGestureRecognizer(homeScreenGesture)
        

    }
    
    @objc func homeBackImageTapped(_ sender: UITapGestureRecognizer) {
        print("Going back to homepage")
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        if let backHomeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreenViewController {
            backHomeVC.modalTransitionStyle = .crossDissolve
            backHomeVC.modalPresentationStyle = .fullScreen
            self.present(backHomeVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension AddFriendViewController: UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: FriendRequestCell.reuseIdentifier, for: indexPath) as! FriendRequestCell
        let req = requests[indexPath.row]
        cell.nameLabel.text = req.displayName
        cell.usernameLabel.text = req.username

        // Handlers
        cell.onConfirm = { [weak self] in
            self?.handleConfirm(at: indexPath)
        }
        cell.onDelete  = { [weak self] in
            self?.handleDelete(at: indexPath)
        }

        return cell
    }
}

// MARK: - Actions
private extension AddFriendViewController {
    func handleConfirm(at indexPath: IndexPath) {
        let name = requests[indexPath.row].displayName
        print("Confirmed \(name)")
        // e.g. call API, then:
        requests.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func handleDelete(at indexPath: IndexPath) {
        let name = requests[indexPath.row].displayName
        print("Deleted \(name)")
        // e.g. call API, then:
        requests.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
