//
//  HomeScreenViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/3/25.
//

import UIKit

extension HomeScreenViewController: NewJournalDelegate {
    func didCreateJournal(_ journal: Journal) {
        journals.append(journal)
        journalCollectionView.reloadData()
    }
}
var journals: [Journal] = []

class HomeScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var journalCollectionView: UICollectionView!
    
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var addFriend: UIImageView!
    
    
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
        let storyboard = UIStoryboard(name: "Stephanie_Storyboard", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsPage") as? SettingsViewController {
            settingsVC.modalTransitionStyle = .crossDissolve
            settingsVC.modalPresentationStyle = .fullScreen
            self.present(settingsVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return journals.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = journalCollectionView.dequeueReusableCell(withReuseIdentifier: "AddJournalCell", for: indexPath)
            cell.layer.cornerRadius = 15
            cell.layer.masksToBounds = true

            return cell
        } else {
            let cell = journalCollectionView.dequeueReusableCell(withReuseIdentifier: "JournalCell", for: indexPath) as! JournalCollectionViewCell
            cell.journalTitle.text = journals[indexPath.row - 1].title
            cell.importanceLabel.text = journals[indexPath.row - 1].importance
            cell.journalView.backgroundColor = journals[indexPath.row - 1].bgColor
//            cell.layer.cornerRadius = 15
//                    cell.layer.masksToBounds = true  // Allow shadows to be visible
            
            cell.contentView.layer.cornerRadius = 15
                    cell.contentView.layer.masksToBounds = true

                    // Apply shadow
                    cell.layer.shadowColor = UIColor.black.cgColor
                    cell.layer.shadowOpacity = 0.4
                    cell.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.masksToBounds = false
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        } else {
            print("Opening \(journals[indexPath.row - 1].title)")
            let storyboard = UIStoryboard(name: "Stephanie_Storyboard", bundle: nil)
            if let openNoteVC = storyboard.instantiateViewController(withIdentifier: "OpenNoteScreen") as? OpenNotebookViewController {
                openNoteVC.modalTransitionStyle = .crossDissolve
                openNoteVC.modalPresentationStyle = .fullScreen
                self.present(openNoteVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createNewJournal(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        if let newJournalVC = storyboard.instantiateViewController(withIdentifier: "NewJournalViewController") as? NewJournalViewController {
            newJournalVC.modalPresentationStyle = .pageSheet
            newJournalVC.delegate = self
            
            if let sheet = newJournalVC.sheetPresentationController {
                sheet.detents = [.medium()] // Makes it take up half the screen
            }
            
            present(newJournalVC, animated: true)
        }
        
    }
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
    }
}

    


