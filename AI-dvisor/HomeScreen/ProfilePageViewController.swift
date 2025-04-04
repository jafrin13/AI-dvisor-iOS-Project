//
//  ProfilePageViewController.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 4/1/25.
//

import UIKit
import FirebaseAuth
import Firebase
import CoreData

class ProfilePageViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var helloUserText: UILabel!
    
    var currentUsername: String = ""
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the profile image view to be circular
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        
        // Obtain user from core and set profile picture and username
        // Fetch and setup user data
       if let userEmail = Auth.auth().currentUser?.email {
           fetchUser(email: userEmail)
       }
       
       errorMessage.text = ""
    }
    
    // Fetch user from core and update UI
    func fetchUser(email: String) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()  // Ensure 'User' is your NSManagedObject subclass
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            if let user = fetchedResults.first {
                currentUser = user
                helloUserText.text = "Hi, \(user.username ?? "")"

                if let imageData = user.profilePicture as Data?, let image = UIImage(data: imageData) {
                    profilePicture.image = image
                }
            }
        } catch {
            print("Error while retrieving data: \(error)")
            errorMessage.text = "Failed to load user data."
        }
    }
    
    // Change the username by request of user
    @IBAction func onChangeUsernameButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Change Username", message: "Enter new username", preferredStyle: .alert)
        
       alertController.addTextField { (textField) in
           textField.placeholder = "New username"
       }
       
       let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned alertController] _ in
           if let newUsername = alertController.textFields?.first?.text, !newUsername.isEmpty {
               self.currentUser?.setValue(newUsername, forKey: "username")
               self.saveContext()
               self.helloUserText.text = "Hi, \(newUsername)"
           }
       }
       
       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
       
       alertController.addAction(updateAction)
       alertController.addAction(cancelAction)
       
       present(alertController, animated: true)
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
    
    // Change password based on user request
    @IBAction func onChangePasswordButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Change Password", message: "Enter new password", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New password"
            textField.isSecureTextEntry = true
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            if let newPassword = alertController.textFields?.first?.text {
                // Update password in Firebase
                self.updatePassword(newPassword: newPassword)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // Helper method that changes password in Firebase
    func updatePassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            if let error = error {
                self.errorMessage.text = "Error updating password: \(error.localizedDescription)"
            } else {
                self.errorMessage.text = "Password updated successfully."
            }
        }
    }
    
    // Change pfp by user request
    @IBAction func onPFPButton(_ sender: Any) {
        // Create an instance of UIImagePickerController
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true  // Allow users to crop the photo

        // Create an action sheet to let the user choose the image source
        let actionSheet = UIAlertController(title: "Select Profile Picture", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet to the user
        present(actionSheet, animated: true, completion: nil)
    }
    
    // To go back to prev. settings VC
    @IBAction func onBackButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - Image Picker Delegate
extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the image from the image picker, either the edited image or the original
        if let editedImage = info[.editedImage] as? UIImage {
            profilePicture.image = editedImage
            self.profilePicture.image = editedImage
            let imageData = editedImage.pngData()
            self.currentUser?.setValue(imageData, forKey: "profilePicture")
            self.saveContext()
        } else if let originalImage = info[.originalImage] as? UIImage {
            profilePicture.image = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
