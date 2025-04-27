//
//  AddFriendViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/19/25.
//

import UIKit

class AddFriendViewController: UIViewController, UITableViewDataSource {
    
    var currentUser: User?

    @IBOutlet weak var homeButton: UIImageView!
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // Hardcoded friend "data" as this was a stretch goal
    private var requests: [FriendRequest] = [
        .init(displayName: "Courtney Johnson", username: "@CourtneyJohnson"),
        .init(displayName: "Stephanie Nguyen",  username: "@StephanieNguyen"),
        .init(displayName: "Lauren Leyendecker",  username: "@LaurenLeyendecker"),
        .init(displayName: "Jafrina Rahman",  username: "@JafrinaRahman")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programmatically set up view of friend requests
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
    
    // Transition back into the home view controller
    @objc func homeBackImageTapped(_ sender: UITapGestureRecognizer) {
        print("Going back to homepage")
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        if let backHomeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreenViewController {
            backHomeVC.modalTransitionStyle = .crossDissolve
            backHomeVC.modalPresentationStyle = .fullScreen
            self.present(backHomeVC, animated: true, completion: nil)
        }
    }
    
    // Rows for table view
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    // Content for each cell in the table view
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: FriendRequestCell.reuseIdentifier, for: indexPath) as! FriendRequestCell
        let req = requests[indexPath.row]
        cell.nameLabel.text = req.displayName
        cell.usernameLabel.text = req.username

        cell.onConfirm = {
            if let currentIndexPath = self.tableView.indexPath(for: cell) {
                self.handleConfirm(at: currentIndexPath)
            }
        }
        
        cell.onDelete = {
            if let currentIndexPath = self.tableView.indexPath(for: cell) {
                self.handleDelete(at: currentIndexPath)
            }
        }
        
        return cell
    }
    
    // Confirm friend
    func handleConfirm(at indexPath: IndexPath) {
        guard requests.indices.contains(indexPath.row) else { return }
        let name = requests[indexPath.row].displayName
        print("Confirmed \(name)")
        requests.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if requests.isEmpty {
            transitionToEmptyView()
        }
    }

    // Delete friend
    func handleDelete(at indexPath: IndexPath) {
        guard requests.indices.contains(indexPath.row) else { return }
        let name = requests[indexPath.row].displayName
        print("Deleted \(name)")
        requests.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if requests.isEmpty {
            transitionToEmptyView()
        }
    }
    
    // Display empty view cell once all requests are confirmed/deleted
    private func transitionToEmptyView() {
        let emptyVC = UIViewController()
        emptyVC.view.backgroundColor = UIColor(red: 228.0/255.0, green: 235.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        let label = UILabel()
        label.text = "No friend requests! Please slide down to exit this screen."
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyVC.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: emptyVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: emptyVC.view.centerYAnchor)
        ])
        
        self.present(emptyVC, animated: true, completion: nil)
    }
}

