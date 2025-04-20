//
//  TimerClass.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/19/25.
//

import Foundation
import UIKit



class TimerClass {
    static let shared = TimerClass()
    private init() {}

    private var timer: Timer?
    private var duration: TimeInterval = 0

    func start(duration: TimeInterval) {
        timer?.invalidate()
        self.duration = duration
        timer = Timer.scheduledTimer(timeInterval: duration,
                                     target: self,
                                     selector: #selector(fire),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc private func fire() {
        timer?.invalidate()
        DispatchQueue.main.async {
            self.showAlert()
        }
    }

    private func showAlert() {
        guard let top = UIApplication.topViewController() else { return }
        let alert = UIAlertController(title: "Time to take a Break!",
                                      message: "Your timer has finished. Go Stretch, Watch a Movie, or Play a Game!",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        top.present(alert, animated: true)
    }
}

extension UIApplication {

    static var keyWindow: UIWindow? {
        return shared
            .connectedScenes
            .lazy
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    // Recursively finds the top‑most view controller from the key window’s root
    static func topViewController(base: UIViewController? = UIApplication.keyWindow?.rootViewController)
      -> UIViewController?
    {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
