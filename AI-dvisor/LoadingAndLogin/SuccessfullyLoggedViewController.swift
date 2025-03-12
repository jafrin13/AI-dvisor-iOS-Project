//
//  SuccessfullyLoggedViewController.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 3/6/25.
//

import UIKit

class SuccessfullyLoggedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.navigateToHomeScreen()
        }
    }
    
    // Note: add a delay and then segue into the true home screen from here
    
    func navigateToHomeScreen() {
            let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreenViewController {
                homeVC.modalTransitionStyle = .crossDissolve
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
            }
        }
}
