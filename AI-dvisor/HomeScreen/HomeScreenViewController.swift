//
//  HomeScreenViewController.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/3/25.
//

import UIKit
import CoreData
import FirebaseAuth

// This extension allows the HomeScreenViewController to handle new journal creation updates.
extension HomeScreenViewController: NewJournalDelegate {
    func didCreateJournal(_ journal: Journal) {
        journals.append(journal)
        journalCollectionView.reloadData()
    }
    
    func didEditJournal(_ journal: Journal, at index: Int) {
        journals[index] = journal
        journalCollectionView.reloadItems(at: [IndexPath(item: index + 1, section: 0)])
    }
}



class HomeScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIColorPickerViewControllerDelegate, EditJournalDelegate {
    
    var journals: [Journal] = []
    var cdJournals: [UserJournal] = []
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var currentUser: User?
    
    @IBOutlet weak var journalCollectionView: UICollectionView!
    
    @IBOutlet weak var settingsImage: UIImageView!
    @IBOutlet weak var addFriend: UIImageView!
    
    var selectedColor: UIColor = .orange
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser()
        
        // These are to allow the Icons to act as buttons when tapped.
        let addFriendGesture = UITapGestureRecognizer(target: self, action: #selector(addFriendImageTapped(_:)))
        let settingsGesture = UITapGestureRecognizer(target: self, action: #selector(settingsImageTapped(_:)))
        
        // This adds that functionality to the UIImageViews above so that a specifc function is called for them
        addFriend.addGestureRecognizer(addFriendGesture)
        settingsImage.addGestureRecognizer(settingsGesture)
        
        journalCollectionView.dataSource = self
        journalCollectionView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        journalCollectionView.addGestureRecognizer(longPressGesture)
        
        
    }
    
    private func fetchCurrentUser() {
      guard let email = Auth.auth().currentUser?.email else {
        fatalError("No Firebase user logged in")
      }

      let req: NSFetchRequest<User> = User.fetchRequest()
      req.predicate = NSPredicate(format: "email == %@", email)

      do {
        if let user = try context.fetch(req).first {
          // found an existing record
          currentUser = user
        } else {
          // **not** found — create one now
          let newUser = User(context: context)
          newUser.email       = email
          newUser.username    = email.components(separatedBy: "@").first
          // you can set a default profile picture here if you want
          try context.save()
          currentUser = newUser
          print("✅ Created Core Data User for \(email)")
        }
      } catch {
        fatalError("Failed fetching/creating User: \(error)")
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadJournals()
        journalCollectionView.reloadData()
      }
    
    private func loadJournals() {
//        guard let user = currentUser else {
//            journals = []
//            return
//          }
//        let req: NSFetchRequest<UserJournal> = UserJournal.fetchRequest()
//        req.predicate = NSPredicate(format: "users == %@", currentUser ?? "Username")
////        req.sortDescriptors = [ .init(key: "createdAt", ascending: false) ]
//        do {
//            let cdJournals = try context.fetch(req)
//            journals = cdJournals.map { entity in
//              // title & importance as before...
//              let title      = entity.title      ?? "Untitled"
//              let importance = entity.importance ?? "!"
//              
//              // turn Data back into UIColor
//              let bgColor: UIColor
//              if let data = entity.bgColor,
//                 let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
//                              as? UIColor {
//                bgColor = color
//              } else {
//                bgColor = .blue
//              }
//
//              return Journal(title: title, importance: importance, bgColor: bgColor)
//        } catch {
//            print("📓 load error:", error)
//            journals = []
//        }
        

        
        // 1️⃣ Ensure we have the logged‑in User
            guard let user = currentUser else {
                cdJournals = []
                journals   = []
                journalCollectionView.reloadData()
                return
            }

            // 2️⃣ Build & run the fetch request
            let req: NSFetchRequest<UserJournal> = UserJournal.fetchRequest()
            req.predicate = NSPredicate(format: "users == %@", user)
            // If you have a createdAt Date attribute, you can sort:
            // req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            do {
                // Fetch the managed objects
                cdJournals = try context.fetch(req)

                // 3️⃣ Map each managed object into your Swift struct
                journals = cdJournals.map { entity in
                    let title      = entity.title      ?? "Untitled"
                    let importance = entity.importance ?? "!"
                    
                    // Unarchive UIColor from Data, fallback to .blue
                    let bgColor: UIColor
                    if let data = entity.bgColor,
                       let color = try? NSKeyedUnarchiver
                                        .unarchivedObject(ofClass: UIColor.self, from: data) {
                        bgColor = color
                    } else {
                        bgColor = .blue
                    }

                    return Journal(
                        title:      title,
                        importance: importance,
                        bgColor:    bgColor
                    )
                }

            } catch {
                print("⚠️ Failed to fetch journals:", error)
                cdJournals = []
                journals   = []
            }

            // 4️⃣ Refresh the UI
            journalCollectionView.reloadData()
    }
    
    // This function is not implemented yet for Alpha but will be implemented for Final
    @objc func addFriendImageTapped(_ sender: UITapGestureRecognizer) {
        print("Go to Add Friend Page")
    }
    
    // This function acts just the same as a pressedButton function but for images.
    @objc func settingsImageTapped(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Stephanie_Storyboard", bundle: nil)
        
        // This statement is to set this variable to a storyboard to allow for the transition to happen
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsPage") as? SettingsViewController {
            // This is the style of how the transition looks
            settingsVC.modalTransitionStyle = .crossDissolve
            settingsVC.modalPresentationStyle = .fullScreen
            self.present(settingsVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return journals.count + 1 // This is +1 to account for the "New Journal" that includes the button
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
    
    // This function is for when a journal has been clicked and it will open that journal
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        } else {
            let storyboard = UIStoryboard(name: "Stephanie_Storyboard", bundle: nil)
            
            // This statement is to set this variable to a storyboard to allow for the transition to happen
            if let openNoteVC = storyboard.instantiateViewController(withIdentifier: "OpenNoteScreen") as? OpenNotebookViewController {
                let selectedJournal = journals[indexPath.row - 1]
                openNoteVC.journalTitle = selectedJournal.title
                openNoteVC.modalTransitionStyle = .crossDissolve
                openNoteVC.modalPresentationStyle = .fullScreen
                self.present(openNoteVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func createNewJournal(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        
        if let newJournalVC = storyboard.instantiateViewController(withIdentifier: "NewJournalViewController") as? NewJournalViewController {
            // This is so it can be a custom style the way it is shown
            newJournalVC.modalPresentationStyle = .pageSheet
            newJournalVC.currentUser = currentUser
            newJournalVC.delegate = self
            
            if let sheet = newJournalVC.sheetPresentationController {
                sheet.detents = [.medium()] // Makes it take up half the screen
            }
            present(newJournalVC, animated: true)
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: journalCollectionView)
        
        // Get the indexPath of the item being long-pressed
        guard let indexPath = journalCollectionView.indexPathForItem(at: point) else { return }
        
        if gesture.state == .began {
            let selectedJournal = journals[indexPath.item - 1]
            showActionSheet(for: selectedJournal, at: indexPath)
        }
    }
    
    func showActionSheet(for journal: Journal, at indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: journal.title, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.editJournal(at: indexPath)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteJournal(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func editJournal(at indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
        if let editJournalVC = storyboard.instantiateViewController(withIdentifier: "EditJournalViewController") as? EditJournalViewController {
            editJournalVC.modalPresentationStyle = .pageSheet
            editJournalVC.delegate = self
            
            let selectedJournal = cdJournals[indexPath.item - 1]
            editJournalVC.userJournal = selectedJournal
                    editJournalVC.journalIndex = indexPath.item - 1
                    editJournalVC.currentUser   = currentUser
            
            if let sheet = editJournalVC.sheetPresentationController {
                sheet.detents = [.medium()] // Makes it take up half the screen
            }
            
            present(editJournalVC, animated: true)
        }
    }
    
    func deleteJournal(at indexPath: IndexPath) {
        journals.remove(at: indexPath.item - 1)
        journalCollectionView.deleteItems(at: [indexPath])
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
    }
    
   

}
