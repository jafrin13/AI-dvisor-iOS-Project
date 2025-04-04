//
//  SettingsViewController.swift
//  AI-dvisor
//
//  Created by Nguyen, Stephanie V on 3/3/25.
//

import UIKit
import FirebaseAuth
import CoreData

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var settings: UILabel!
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    @IBOutlet weak var logOffButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the profile image view to be circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        
        // Obtain specific user from core and set profile picture
        if let email = Auth.auth().currentUser?.email {
            fetchUser(email: email)
        }
    }
    
    // Fetch user from core and update UI
    func fetchUser(email: String) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest() 
        fetchRequest.predicate = NSPredicate(format: "email MATCHES %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                if let imageData = user.profilePicture as Data?, let image = UIImage(data: imageData) {
                    profilePicture.image = image
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    // This function loads in the HomeScreenStoryboard when pressed
    @IBAction func backButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        
        // This statement is to set this variable to a storyboard to allow for the transition to happen
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreenViewController {
            // This is the style of how the transition looks
            homeVC.modalTransitionStyle = .crossDissolve
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
    }
    
    // This function loads in the LoginandSignupStoryboard when pressed
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // This statement is to set this variable to a storyboard to allow for the transition to happen
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginScreen") as? LoginViewController {
            // This is the style of how the transition looks
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onProfileButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "profilePageSegue", sender: self)
    }
    
    // Reload the data to reflect a possible PFP change
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let email = Auth.auth().currentUser?.email {
            fetchUser(email: email)
        }
    }
}
    

    

   
   


