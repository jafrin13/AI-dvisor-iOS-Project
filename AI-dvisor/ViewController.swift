//
//  ViewController.swift
//  AI-dvisor
//
//  Created by Jafrina Rahman on 2/28/25.
//

import UIKit

class ViewController: UIViewController {

    let loginSegueIdentifier = "LoginSegue"
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarTurtle: UIImageView!
    
    // Variables for animating the progress bar
    var timer: Timer?
    var currentProgress: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0.0
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 4)
        animateProgressBar()
    }

    // Animates the loading bar to completion
    func animateProgressBar() {
        // Schedule a timer to fire every 0.1 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Increment the progress value
            if self.currentProgress < 1.0 {
                self.currentProgress += 0.01
                self.progressBar.setProgress(self.currentProgress, animated: true)
                self.updateTurtlePosition()
            } else {
                // Invalidate the timer once the bar is full
                self.timer?.invalidate()
                self.timer = nil
                // Perform the segue to the login screen
                self.performSegue(withIdentifier: self.loginSegueIdentifier, sender: self)
            }
        }
    }
    
    // Animates the turtle to follow the animation of the edge of the loading bar
    func updateTurtlePosition() {
            // Calculate the new x pos for the turtle based on progress
            let progressBarWidth = progressBar.frame.width
            // Multiply the width by the current progress to get the x-offset
            let progressX = CGFloat(currentProgress) * progressBarWidth
            // Adjust the turtle's center.x to the progress bar's x-origin plus the calculated offset
            progressBarTurtle.center.x = progressBar.frame.origin.x + progressX
    }
    
    // Makes the progress bar visually rounder at the edges
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Round the entire progress view
        progressBar.layer.cornerRadius = progressBar.frame.height / 2
        progressBar.clipsToBounds = true

        // Round each subview (this includes the progress and track layers)
        for subview in progressBar.subviews {
            subview.layer.cornerRadius = subview.frame.height / 2
            subview.clipsToBounds = true
        }
    }
}

