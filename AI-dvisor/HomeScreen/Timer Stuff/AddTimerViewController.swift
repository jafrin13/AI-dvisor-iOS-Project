//
//  AddTimerViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 4/19/25.
//

import UIKit

protocol AddTimerDelegate: AnyObject {
    func didAddTimer()
}

var pickerData = ["30 minutes","45 minutes","1 hour","1 hour 15 minutes","1 hour 30 minutes","1 hour 45 minutes","2 hours","10 Seconds"]

class AddTimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    var duration: TimeInterval = 0
    var timer: Timer?
    var selectedRow = 0
    
    var delegate: AddTimerDelegate?
    
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        timePicker.delegate = self
        timePicker.dataSource = self
        
        // Style for rounded corners
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        
        // Style for Rounded Buttons
        setButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = pickerData[row]
        switch selected {
        case "30 minutes":
            // Doing this math so it convert seconds to minutes becuase "Time Interval" is only in seconds
            duration =  30*60
            selectedRow = 0
        case "45 minutes":
            duration = 45*60
            selectedRow = 1
        case "1 hour":
            duration = 60*60
            selectedRow = 2
        case "1 hour 15 minutes":
            duration = 75*60
            selectedRow = 3
        case "1 hour 30 minutes":
            duration =  90*60
            selectedRow = 4
        case "1 hour 45 minutes":
            duration = 105*60
            selectedRow = 5
        case "2 hours":
            duration = 120*60
            selectedRow = 6
        // This case was for the demo but i'm leaving it in for grading purposes
        case "10 Seconds":
            duration = 10
            selectedRow = 7
        default:
            duration =  0
        }
    }
    
    @IBAction func setButtonTapped(_ sender: Any) {
        // This line is so that the timer runs no matter what view you are on
        // So that the alert will show up on any screen not just the that set it. 
        TimerClass.shared.start(duration: duration)
        delegate?.didAddTimer()
        self.dismiss(animated: true)
        
    }
    
    @IBAction func cancleButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
