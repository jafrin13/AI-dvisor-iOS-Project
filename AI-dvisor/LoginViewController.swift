//
//  LoginViewController.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 3/2/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    let createAccountSegueIdentifier = "CreateAccountSegue"
    let successfullyLoggedInIdentifier = "SuccessfullyLoggedSegue"
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginErrorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }
    
    // If user attempts to login their credentials will be verified by Firebase and then logged in
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) {
            (authResult, error) in
            if let error = error as NSError? {
                self.loginErrorMessage.text = "\(error.localizedDescription)"
            } else {
                // Perform segue into the home screen only IF login was successful
                Auth.auth().addStateDidChangeListener() { (auth, user) in
                    if user != nil {
                        self.performSegue(withIdentifier: self.successfullyLoggedInIdentifier, sender: nil)
                        // Successful log in, clear fields
                        self.passwordTextField = nil
                        self.usernameTextField = nil
                    }
                }
                self.loginErrorMessage.text = ""
            }
        }
    }
    
    // If user does not have an account, this will take them to the VC for account creation
    @IBAction func signUpButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: self.createAccountSegueIdentifier, sender: self)
    }

}
