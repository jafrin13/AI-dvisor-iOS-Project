//
//  NewJournalViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/6/25.
//

import UIKit
import CoreData

protocol NewJournalDelegate: AnyObject {
    func didCreateJournal(_ journal: Journal)
//    func didEditJournal(_ journal: Journal)
}

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

class NewJournalViewController: UIViewController, UITextFieldDelegate{
    
    var currentUser: User!
    
    @IBOutlet weak var journalNameTextFeild: UITextField!
    
    @IBOutlet weak var importancePreview: UILabel!
    
    @IBOutlet weak var colorSelectorButton: UIButton!
    @IBOutlet weak var importanceSelectorButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: NewJournalDelegate?
    
    var selectedColor: UIColor = .blue // Default Color
    var importanceLevel = "!" // Default Importance Value
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style for rounded corners
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        importancePreview.text = ""
        
        // Style for Rounded Buttons
        saveButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        
        journalNameTextFeild.delegate = self
        
    }
    
    // Called when 'return' key pressed

        func textFieldShouldReturn(_ textField:UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // Called when the user clicks on the view outside of the UITextField

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    @IBAction func colorSelectorPressed(_ sender: Any) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
    
    @IBAction func importanceSelectorPressed(_ sender: Any) {
        let importanceController = UIAlertController(
            title: "How Important?",
            message: "Please select an importance:",
            preferredStyle: .actionSheet)
        
        importanceController.addAction(UIAlertAction(
            title: "! - Meh",
            style: .default)
                                       {action in self.importanceLevel = "!"
            self.importanceSelectorButton.setTitle(importanceController.actions[0].title, for: .normal)})
        
        importanceController.addAction(UIAlertAction(
            title: "!! - Kinda Serious",
            style: .default)
                                       {action in self.importanceLevel = "!!"
            self.importanceSelectorButton.setTitle(importanceController.actions[1].title, for: .normal)})
        
        importanceController.addAction(UIAlertAction(
            title: "!!! - My Grade Is On The Line",
            style: .default)
                                       {action in self.importanceLevel = "!!!"
            self.importanceSelectorButton.setTitle(importanceController.actions[2].title, for: .normal)})
        
        present(importanceController, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let journalTitle = journalNameTextFeild.text ?? "New Journal"
        let selectedImportance = importanceLevel
        let selectedColor = self.selectedColor
        
//        let newJournal = Journal(title: journalTitle, importance: selectedImportance, bgColor: selectedColor)
//        delegate?.didCreateJournal(newJournal)
        
        let newJournal = Journal(
              title:      journalTitle,
              importance: selectedImportance,
              bgColor:    selectedColor
            )
            delegate?.didCreateJournal(newJournal)
        
        let newCDJournal = NSEntityDescription.insertNewObject(forEntityName: "UserJournal", into: context)
        newCDJournal.setValue(journalTitle, forKey: "title")
        newCDJournal.setValue(selectedImportance, forKey: "importance")
        newCDJournal.setValue(selectedColor, forKey: "bgColor")
        
        saveContext()
        
        dismiss(animated: true)
    }
    
    // Saves the changes in core
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

