//
//  NewJournalViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/6/25.
//

import UIKit

protocol NewJournalDelegate: AnyObject {
    func didCreateJournal(_ journal: Journal)
}

class NewJournalViewController: UIViewController{
    
    @IBOutlet weak var journalNameTextFeild: UITextField!
    
    weak var delegate: NewJournalDelegate?
    
    var selectedColor: UIColor = .blue // Default Color
    var importanceLevel = "!" // Default Importance Value
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style for rounded corners
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }
    
    
    @IBAction func colorSelectorPressed(_ sender: Any) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)    }
    
    @IBAction func importanceSelectorPressed(_ sender: Any) {
        let importanceController = UIAlertController(
            title: "How Important?",
            message: "Please select an importance:",
            preferredStyle: .actionSheet)
        
        importanceController.addAction(UIAlertAction(
            title: "! - Meh",
            style: .default)
                                       {action in self.importanceLevel = "!"})
        importanceController.addAction(UIAlertAction(
            title: "!! - Kinda Serious",
            style: .default)
                                       {action in self.importanceLevel = "!!"})
        importanceController.addAction(UIAlertAction(
            title: "!!! - My Grade Is On The Line",
            style: .default)
                                       {action in self.importanceLevel = "!!!"})
        
        present(importanceController, animated: true)    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let journalTitle = journalNameTextFeild.text ?? "New Journal"
        let selectedImportance = importanceLevel
        
        let newJournal = Journal(title: journalTitle, importance: selectedImportance, bgColor: selectedColor)
        delegate?.didCreateJournal(newJournal)
        
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
    
    extension NewJournalViewController: UIColorPickerViewControllerDelegate {
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            selectedColor = viewController.selectedColor
        }
}
