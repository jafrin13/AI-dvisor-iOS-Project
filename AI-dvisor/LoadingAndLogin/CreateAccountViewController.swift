//
//  CreateAccountViewController.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 3/2/25.
//
import UIKit
import FirebaseAuth
import CoreData

// Ptr to app delegate so we can get context (buffer/cache/notepad)
let appDelegate = UIApplication.shared.delegate as! AppDelegate
// This will write it out to core data unless its saved in it; this is the lazy var
// from app delegate -- the container from over there
let context = appDelegate.persistentContainer.viewContext

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    let successfullyLoggedInIdentifier = "CreatedAccountSegue"

    @IBOutlet weak var newUserPasswordTextField: UITextField!
    @IBOutlet weak var newUserUsernameTextField: UITextField!
    @IBOutlet weak var reEnterPasswordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // For keyboard to close when tap on screen
        newUserPasswordTextField.delegate = self
        newUserUsernameTextField.delegate = self
        reEnterPasswordField.delegate = self
        
        newUserPasswordTextField.isSecureTextEntry = true
        reEnterPasswordField.isSecureTextEntry = true
    }
    
    // Validation Helper Methods
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 6
        return password.count >= minPasswordLength
    }
    
    // Validates all user inputs to be valid user/pass for an account
    func validateFields() -> String? {
        guard let email = newUserUsernameTextField.text,
              !email.isEmpty,
              isValidEmail(email) else {
            return "Please enter a valid email address."
        }
        
        guard let password = newUserPasswordTextField.text,
              !password.isEmpty,
              isValidPassword(password) else {
            return "Password must be at least 6 characters."
        }
        
        guard let reenteredPassword = reEnterPasswordField.text,
              !reenteredPassword.isEmpty else {
            return "Please confirm your password."
        }
        
        guard password == reenteredPassword else {
            return "Passwords do not match."
        }
        
        return nil  // No error
    }
    
    // Let's user create a new account
    @IBAction func nextButtonPressed(_ sender: Any) {
        // Check for input errors using the validation function
        if let error = validateFields() {
            errorMessage.text = error
            return
        }
        
        // All validations passed, proceed to create a new user
        guard let email = newUserUsernameTextField.text,
              let password = newUserPasswordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
                // Perform segue into the home screen only if account creation was successful
                Auth.auth().addStateDidChangeListener() {
                    (auth, user) in
                    if user != nil {
                        // Store new user into core data
                        self.storeUser()
                        self.performSegue(withIdentifier: self.successfullyLoggedInIdentifier, sender: nil)
                        // Successful login, clear fields
                        self.newUserPasswordTextField = nil
                        self.reEnterPasswordField = nil
                        self.newUserUsernameTextField = nil
                    }
                }
            }
        }
    }
    
    // If user no longer wants to create an account, they can go back to login VC
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // This will create a new user entity to store into Core Data
    func storeUser() {
        guard let email = Auth.auth().currentUser?.email else { return }
        let username = email.components(separatedBy: "@").first ?? email

        // Load the default profile image
        let defaultProfileImg = UIImage(named: "pfpTurtle")!
        let imageData = defaultProfileImg.pngData()

        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        newUser.setValue(username, forKey: "username")
        newUser.setValue(email, forKey: "email")
        newUser.setValue(imageData, forKey: "profilePicture")

        saveContext()
    }
    
    // Saves the changes in core
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
