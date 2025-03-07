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
    
    // Let's user create a new account
    @IBAction func nextButtonPressed(_ sender: Any) {
        // Ensure both password fields have text
        guard let password = newUserPasswordTextField.text,
                let reenteredPassword = reEnterPasswordField.text,
                  !password.isEmpty, !reenteredPassword.isEmpty else {
            errorMessage.text = "Please fill in all password fields."
            return
        }
            
        // Check if the two passwords match
        if password != reenteredPassword {
            errorMessage.text = "Passwords do not match."
            return
        }
        
        // Create new user once passwords are okay
        Auth.auth().createUser(withEmail: newUserUsernameTextField.text!,
                                password: newUserPasswordTextField.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
                // Perform segue into the home screen only IF account creation was successful
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
