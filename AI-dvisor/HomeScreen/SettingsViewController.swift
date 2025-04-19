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
    @IBOutlet weak var darkLightSegCtrl: UISegmentedControl!
    
    var currentUser: User?
    
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
                currentUser = user
                if let imageData = user.profilePicture as Data?, let image = UIImage(data: imageData) {
                    profilePicture.image = image
                }
                // Set dark or light mode
                let isDarkMode = user.value(forKey: "darkMode") as? Bool ?? false
                onDarkLightMode(darkMode: isDarkMode)
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    // For Dark/Light Mode
    func onDarkLightMode(darkMode: Bool) {
        if (darkMode) {
            // Dark mode: Set a navy blue background
            view.backgroundColor = UIColor(red: 40/255.0, green: 40/255.0, blue: 100/255.0, alpha: 1.0)
            darkLightSegCtrl.selectedSegmentIndex = 1
        } else {
            // Light mode: Set the background to the original light color
            view.backgroundColor = UIColor(red: 245/255.0, green: 224/255.0, blue: 216/255.0, alpha: 1.0)
            darkLightSegCtrl.selectedSegmentIndex = 0
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
    
    // For profile changes communication
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "profilePageSegue" {
           if let profilePageVC = segue.destination as? ProfilePageViewController {
               // Set self as the delegate so that the profile update is communicated back
               profilePageVC.delegate = self
           }
       }
    }
    
    // For Dark/Light Mode
    @IBAction func onDarkLightSegCtrl(_ sender: Any) {
        // Based on the currently selected segment...
        switch darkLightSegCtrl.selectedSegmentIndex {
        case 0:
            // Light mode; selected segment is 0
            self.currentUser?.setValue(false, forKey: "darkMode")
            self.saveContext()
            // Reset background color to the light mode color
            view.backgroundColor = UIColor(red: 245/255.0, green: 224/255.0, blue: 216/255.0, alpha: 1.0)

        case 1:
            // Dark mode; selected segment is 1
            self.currentUser?.setValue(true, forKey: "darkMode")
            self.saveContext()
            // Change background color to navy blue for dark mode
            view.backgroundColor = UIColor(red: 40/255.0, green: 40/255.0, blue: 100/255.0, alpha: 1.0)
        default:
            // Best practice: handle the unexpected case
            print("This should never happen!")
        }
    }
    
    // Saves the changes to core
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// For profile changes communication
extension SettingsViewController: ProfilePageDelegate {
    func profilePageDidUpdateProfilePicture(_ newProfilePicture: UIImage) {
        // Update the profile picture immediately
        self.profilePicture.image = newProfilePicture
    }
}
   
    

    

   
   


