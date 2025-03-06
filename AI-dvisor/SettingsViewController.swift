//
//  SettingsViewController.swift
//  AI-dvisor
//
//  Created by Nguyen, Stephanie V on 3/3/25.
//

import UIKit

class SettingsViewController: UIViewController {


   
    @IBOutlet weak var notifications: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var onButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel.font = UIFont(name: "BakbakOne-Regular", size: myLabel.font.pointSize)
        notifications.font = UIFont(name: "BakbakOne-Regular", size: notifications.font.pointSize)
        
        
        onButton.titleLabel?.font = UIFont(name: "BakbakOne-Regular", size: 18)
        offButton.titleLabel?.font = UIFont(name: "BakbakOne-Regular", size: 18)


        

        // Do any additional setup after loading the view.
    }
    
    
    

    

   
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
