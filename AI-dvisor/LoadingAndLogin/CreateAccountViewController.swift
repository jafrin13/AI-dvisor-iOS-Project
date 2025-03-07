//
//  CreateAccountViewController.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 3/2/25.
//
import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController {

    let successfullyLoggedInIdentifier = "CreatedAccountSegue"

    @IBOutlet weak var newUserPasswordTextField: UITextField!
    @IBOutlet weak var newUserUsernameTextField: UITextField!
    @IBOutlet weak var reEnterPasswordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
