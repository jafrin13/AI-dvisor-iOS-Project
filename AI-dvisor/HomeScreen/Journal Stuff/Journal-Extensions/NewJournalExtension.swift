//
//  NewJournalExtension.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/27/25.
//

import Foundation
import UIKit

// This extension makes the NewJournalViewController conform to
// UIColorPickerViewControllerDelegate without having the required methods
extension NewJournalViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        colorSelectorButton.backgroundColor = viewController.selectedColor
        colorSelectorButton.tintColor = viewController.selectedColor
        colorSelectorButton.setTitle( "", for: .normal)
    }
}
