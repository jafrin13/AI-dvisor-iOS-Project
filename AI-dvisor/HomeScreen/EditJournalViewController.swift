//
//  EditJournalViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/3/25.
//

import UIKit

protocol EditJournalDelegate: AnyObject {
    func didEditJournal(_ journal: Journal, at index: Int)
}

extension EditJournalViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        editColorButton.backgroundColor = viewController.selectedColor
        editColorButton.tintColor = viewController.selectedColor
        editColorButton.setTitle( "", for: .normal)
    }
}

class EditJournalViewController: UIViewController {

    @IBOutlet weak var editColorButton: UIButton!
    @IBOutlet weak var editImportanceButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    weak var delegate: EditJournalDelegate?
    
    var selectedColor: UIColor = .red
    var importanceLevel = "!"
    
    var journal: Journal?
    var journalIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style for rounded corners
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        
        // Style for Rounded Buttons
        saveBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10

    }
    
    @IBAction func editColorPressed(_ sender: Any) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
    
    @IBAction func editImportancePressed(_ sender: Any) {
        let importanceController = UIAlertController(
            title: "How Important?",
            message: "Please select an importance:",
            preferredStyle: .actionSheet)
        
        importanceController.addAction(UIAlertAction(
            title: "! - Meh",
            style: .default)
                                       {action in self.importanceLevel = "!"
            self.editImportanceButton.setTitle(importanceController.actions[0].title, for: .normal)})
        
        importanceController.addAction(UIAlertAction(
            title: "!! - Kinda Serious",
            style: .default)
                                       {action in self.importanceLevel = "!!"
            self.editImportanceButton.setTitle(importanceController.actions[1].title, for: .normal)})
        
        importanceController.addAction(UIAlertAction(
            title: "!!! - My Grade Is On The Line",
            style: .default)
                                       {action in self.importanceLevel = "!!!"
            self.editImportanceButton.setTitle(importanceController.actions[2].title, for: .normal)})
        
        present(importanceController, animated: true)
    }
    
    

    @IBAction func updateBtnPressed(_ sender: Any) {
        let journalTitle = nameTextField.text ?? "New Journal"
        let selectedImportance = importanceLevel
        let index = journalIndex ?? 0
        let updatedJournal = Journal(title: journalTitle, importance: selectedImportance, bgColor: selectedColor)
        delegate?.didEditJournal(updatedJournal, at: index)
        
        dismiss(animated: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    

}
