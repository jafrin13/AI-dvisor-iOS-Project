//
//  SettingsViewController.swift
//  AI-dvisor
//
//  Created by Nguyen, Stephanie V on 3/3/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    
    @IBOutlet weak var notifications: UILabel!
    
    @IBOutlet weak var settings: UILabel!
    
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    
    
    @IBOutlet weak var logOffButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreenViewController {
            homeVC.modalTransitionStyle = .crossDissolve
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginScreen") as? LoginViewController {
            loginVC.modalTransitionStyle = .crossDissolve
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
    

    

   
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

