//
//  ExtensionTimerClass.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/27/25.
//

import Foundation
import UIKit


extension UIApplication {
    
    static var keyWindow: UIWindow? {
        return shared
            .connectedScenes
            .lazy
        // This is atating that I only want the screens dedicated to our app
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    // Recursively finds the top‑most view controller from the key window’s root
    static func topViewController(base: UIViewController? = UIApplication.keyWindow?.rootViewController)
    -> UIViewController? {
        // If the base is a navigation controller, go farther into its visible view controller
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        // If the base is a tab bar controller, go farther into the selected tab's view controller
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        // If the base is presenting another view controller, go farther into that
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        // You have found the top most view controller
        return base
    }
}
