//
//  EditJournalExtension.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/27/25.
//

import Foundation
import UIKit

// This extension makes the NewJournalViewController conform to
// UIColorPickerViewControllerDelegate without having the required methods
extension EditJournalViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        editColorButton.backgroundColor = viewController.selectedColor
        editColorButton.tintColor = viewController.selectedColor
        editColorButton.setTitle( "", for: .normal)
    }
}
