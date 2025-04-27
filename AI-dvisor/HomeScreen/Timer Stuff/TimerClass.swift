//
//  TimerClass.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/19/25.
//

import Foundation
import UIKit

class TimerClass {
    // This is so it can be called in the AddTimerViewController Class
    static let shared = TimerClass()
    private init() {}

    private var timer: Timer?
    private var duration: TimeInterval = 0

    func start(duration: TimeInterval) {
        timer?.invalidate()
        self.duration = duration
        timer = Timer.scheduledTimer(timeInterval: duration,
                                     target: self,
                                     selector: #selector(timerFinish),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc private func timerFinish() {
        timer?.invalidate()
        DispatchQueue.main.async {
            self.showAlert()
        }
    }

    private func showAlert() {
        // This is refering to whatever viewcontroller is on the screen at that moment
        guard let top = UIApplication.topViewController() else { return }
        let alert = UIAlertController(title: "Time to take a Break!",
                                      message: "Your timer has finished. Go Stretch, Watch a Movie, or Play a Game!",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        top.present(alert, animated: true)
    }
}

