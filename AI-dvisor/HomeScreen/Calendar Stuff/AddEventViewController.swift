//
//  AddEventViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/19/25.
//

import UIKit
import CoreData
import FirebaseAuth
import EventKit

protocol AddEventDelegate: AnyObject {
    func didAddEvent()
}

class AddEventViewController: UIViewController {
    let event = EKEventStore()
    
    var currentUser: User!
    
    var userJournal: Journal!
    var journals: [Journal] = []
    
    var delegate: AddEventDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var assignmentTextfield: UITextField!
    @IBOutlet weak var selectJournalDD: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style for rounded corners
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        
        // Style for Rounded Buttons
        addButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        selectJournalDD.layer.cornerRadius = 10
        
        requestCalendarPermission()
        
    }
    
    // This is just like the notifications alert we did in class.
    func requestCalendarPermission() {
        event.requestWriteOnlyAccessToEvents { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.journalDropDown()
                } else {
                    self.showCalendarDeniedAlert()
                }
            }
        }
    }
    
    func showCalendarDeniedAlert() {
        let alert = UIAlertController(
            title: "Calendar Access Denied",
            message: "Please enable Calendars in Settings > Privacy & Security > Calendars.",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // This is so the user can select a specific journal in which they want the reminder for.
    func journalDropDown() {
        // Create one UIAction per Journal
        let actions = journals.map { journal in
            UIAction(title: journal.title) { [weak self] _ in
                self?.userJournal = journal
                self?.selectJournalDD.setTitle(journal.title, for: .normal)
            }
        }
        
        // Build the menu & attach it
        selectJournalDD.menu = UIMenu(
            title: "Choose Subject",
            children: actions
        )
        selectJournalDD.showsMenuAsPrimaryAction = true
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        guard let journal = userJournal else { return }
        let eventDate = datePicker.date
        
        addEventToCalendar(title: assignmentTextfield.text ?? journal.title, on: eventDate) { success, error in
            DispatchQueue.main.async {
                let title = success ? "Saved!" : "Error"
                let msg   = success ? "Your event was added to Calendar." : (error?.localizedDescription ?? "Unknown error")
                let alert = UIAlertController(title: title,
                                              message: msg,
                                              preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        dismiss(animated: true)
    }
    
    func addEventToCalendar(
        title: String,
        on date: Date,
        // This completeion is basically a break statement to leave whenever it encounters an error.
        completion: @escaping (Bool, Error?) -> Void) {
            
        let addedEvent = EKEvent(eventStore: event)
            addedEvent.title     = title
            addedEvent.startDate = date
            addedEvent.endDate   = date.addingTimeInterval(60*60)
            addedEvent.calendar  = event.defaultCalendarForNewEvents
        
        let alarm = EKAlarm(relativeOffset: 0) // 0 seconds before start = at start
            addedEvent.alarms = [ alarm ]
        
        do {
            try event.save(addedEvent, span: .thisEvent)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
