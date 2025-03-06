//
//  HomeScreenViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/3/25.
//

import UIKit

class HomeScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var journalCollectionView: UICollectionView!
    
//    @IBOutlet weak var journalView: UIView!
    
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var addFriend: UIImageView!
    
    var journals: [Journal] = []
    var selectedColor: UIColor = .orange
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addFriendGesture = UITapGestureRecognizer(target: self, action: #selector(addFriendImageTapped(_:)))
        
        let settingsGesture = UITapGestureRecognizer(target: self, action: #selector(settingsImageTapped(_:)))
        
        addFriend.addGestureRecognizer(addFriendGesture)
        settingsImage.addGestureRecognizer(settingsGesture)
        
        journalCollectionView.dataSource = self
        journalCollectionView.delegate = self
    }
    
    @objc func addFriendImageTapped(_ sender: UITapGestureRecognizer) {
        print("Go to Add Friend Page")
    }
    
    @objc func settingsImageTapped(_ sender: UITapGestureRecognizer) {
        print("Go to Setting Page")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return journals.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = journalCollectionView.dequeueReusableCell(withReuseIdentifier: "AddJournalCell", for: indexPath)
            return cell
        } else {
            let cell = journalCollectionView.dequeueReusableCell(withReuseIdentifier: "JournalCell", for: indexPath) as! JournalCollectionViewCell
            cell.journalTitle.text = journals[indexPath.row - 1].title
            cell.importanceLabel.text = journals[indexPath.row - 1].importance
            cell.journalView.backgroundColor = journals[indexPath.row - 1].bgColor
            return cell
        }
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                if indexPath.row == 0 {
                    return
                } else {
                    print("Opening \(journals[indexPath.row - 1].title)")
                }
            }
            
    @IBAction func createNewJournal(_ sender: Any) {
        let alert = UIAlertController(title: "New Journal", message: "Customize your journal", preferredStyle: .alert)

            // Add Text Field for Journal Name
            alert.addTextField { textField in
                textField.placeholder = "Enter journal name"
            }

            // Importance Selection (Segmented Control Alternative)
            let importanceOptions = ["!", "!!", "!!!"]
            let importancePicker = UISegmentedControl(items: importanceOptions)
            importancePicker.selectedSegmentIndex = 1 // Default to "!!"

            // Color Picker Button (Opens System Color Picker)
            let colorPickerAction = UIAlertAction(title: "Choose Color", style: .default) { _ in
                let colorPicker = UIColorPickerViewController()
                colorPicker.delegate = self
                self.present(colorPicker, animated: true)
            }

//             Save Button
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                let journalTitle = alert.textFields?.first?.text ?? "New Journal"
                let selectedImportance = importanceOptions[importancePicker.selectedSegmentIndex]

                let newJournal = Journal(title: journalTitle, importance: selectedImportance, bgColor: self.selectedColor)
                self.journals.append(newJournal)
                self.journalCollectionView.reloadData()
            }

            // Cancel Button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            // Add Actions
            alert.addAction(colorPickerAction)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)

            // Present Action Sheet
            present(alert, animated: true)
        
        

    }
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            selectedColor = viewController.selectedColor
        }
    }
    


