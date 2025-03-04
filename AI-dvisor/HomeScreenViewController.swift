//
//  HomeScreenViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/3/25.
//

import UIKit

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var addFriend: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addFriendGesture = UITapGestureRecognizer(target: self, action: #selector(addFriendImageTapped(_:)))
        
        let settingsGesture = UITapGestureRecognizer(target: self, action: #selector(settingsImageTapped(_:)))
        
        addFriend.addGestureRecognizer(addFriendGesture)
        settingsImage.addGestureRecognizer(settingsGesture)
    }
    
    @objc func addFriendImageTapped(_ sender: UITapGestureRecognizer) {
        print("Go to Add Friend Page")
    }
    
    @objc func settingsImageTapped(_ sender: UITapGestureRecognizer) {
        print("Go to Setting Page")
    }
    
}
