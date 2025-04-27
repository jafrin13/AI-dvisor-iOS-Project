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



class EditJournalViewController: UIViewController, UITextFieldDelegate {
    
    var currentUser: User!
    
    var userJournal: UserJournal!
    
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
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        
        // Style for Rounded Buttons
        saveBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        editColorButton.layer.cornerRadius = 10
        editImportanceButton.layer.cornerRadius = 10
        
        nameTextField.delegate = self
        
        // This is setting the properties of those fields to teh current properties of the journal
        nameTextField.text = userJournal.title
        importanceLevel = userJournal.importance ?? "!"
        editImportanceButton.titleLabel?.text = importanceLevel
        
        // Unarchive color for the picker preview:
        if let data = userJournal.bgColor,
           let color = try? NSKeyedUnarchiver
            .unarchivedObject(ofClass: UIColor.self, from: data) {
            selectedColor = color
        }
        
        // This is setting the color of the button to the current color of the journal
        editColorButton.backgroundColor = selectedColor
        editColorButton.tintColor = selectedColor
        editColorButton.setTitle( "", for: .normal)
        
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
        // Safely unwrap the managed object and text field
        guard let journal = userJournal else {
            print("No journal to update")
            dismiss(animated: true)
            return
        }
        
        let rawText = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newTitle = rawText.isEmpty ? "New Journal" : rawText
        let newImportance = importanceLevel
        
        // Archive the selectedColor into Data
        let colorData: Data
        do {
            colorData = try NSKeyedArchiver.archivedData(
                withRootObject: selectedColor,
                requiringSecureCoding: false
            )
        } catch {
            print("Color archiving failed:", error)
            colorData = Data()
        }
        
        // Write back into the managed object
        journal.title      = newTitle
        journal.importance = newImportance
        journal.bgColor    = colorData
        
        // Persist to Core Data
        do {
            try context.save()
        } catch {
            print("Failed to save edits:", error)
        }
        
        // Update the in‑memory struct/UI
        let updated = Journal(
            title:      newTitle,
            importance: newImportance,
            bgColor:    selectedColor
        )
        if let jIndex = journalIndex {
            delegate?.didEditJournal(updated, at: jIndex)
        }
        dismiss(animated: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
