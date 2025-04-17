//
//  ChatbotViewController.swift
//  AI-dvisor
//
//  Created by Mac Laptop on 3/3/25.
//


import UIKit
import MessageKit
import InputBarAccessoryView
import CoreData
import FirebaseAuth

class ChatbotViewController: MessagesViewController {
    
    var delegate: UIViewController!
    var noteFilePath: String = "" // path to the doc we want to display in Firebase passed from segue
    var folderFilePath: String = "" // path to the folder we want to store any generated content to passed from segue
    var localFileURL: URL? // local cached file retreived from Firebase
    var studyMaterialType: String = ""
    
    var messages: [Message] = [] // stores the messages in the chat
    let currentUser = Sender(senderId: "self", displayName: "User")
    let chatbot = Sender(senderId: "bot", displayName: "AI-dvisor")
    let defaultMessage: String = "Type message here..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Obtain specific user from core
        var darkMode: Bool = false
        if let email = Auth.auth().currentUser?.email {
            darkMode = fetchUser(email: email)
        }
        setupTopBar(darkMode: darkMode)
        // save room for the top of the VC (can change value if too much or too little)
        messagesCollectionView.contentInset = UIEdgeInsets(top: 163, left: 0, bottom: 0, right: 0)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.text = defaultMessage
        messageInputBar.inputTextView.textColor = .lightGray
    }
    
    // Fetch user from core and update UI
    func fetchUser(email: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email MATCHES %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                // Set dark or light mode
                let isDarkMode = user.value(forKey: "darkMode") as? Bool ?? false
                return isDarkMode
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
        return false
    }
    
    private func setupTopBar(darkMode: Bool) {
        // Create Background View for the Top Bar
        let topBarView = UIView()
        if (darkMode) {
            topBarView.backgroundColor = UIColor(red:  50/255, green:  50/255, blue:  50/255, alpha: 1)
        } else {
            topBarView.backgroundColor = UIColor(red: 255/255.0, green: 229/255.0, blue: 217/255.0, alpha: 1.0)
        }
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        // Create Back Button
        let backButton = UIButton(type: .system)
        backButton.setTitle("< Back", for: .normal)
        if (darkMode) {
            backButton.setTitleColor(.white, for: .normal)
        } else {
            backButton.setTitleColor(UIColor(red: 206/255.0, green: 212/255.0, blue: 179/255.0, alpha: 1.0), for: .normal)
        }
        backButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 32)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        // Create Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Chat"
        if (darkMode) {
            titleLabel.textColor = UIColor(.white)
        } else {
            titleLabel.textColor = UIColor(red: 157/255.0, green: 129/255.0, blue: 137/255.0, alpha: 1.0)
        }
        titleLabel.font = UIFont(name: "Marker Felt", size: 32)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Constraints
        NSLayoutConstraint.activate([
            // Top Bar View Constraints
            topBarView.topAnchor.constraint(equalTo: view.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 163), // Adjust height to fit title & button

            // Back Button Constraints
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),

            // Title Label Constraints
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Align to left with padding
            titleLabel.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: -40) // Moves it down
        ])
    }
        
    @objc private func backButtonPressed() {
        dismiss(animated: true, completion: nil) // Dismiss the current view controller
    }
}

extension ChatbotViewController: MessagesDataSource {
    var currentSender: any MessageKit.SenderType {
        return currentUser
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatbotViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultMessage {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultMessage
            textView.textColor = .lightGray
        }
    }
}

extension ChatbotViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let newMessage = Message(
            sender: currentSender,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(text)
        )
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
        
        // potentially add typing indicator here
        
        // send message to open AI
        OpenAIConnector.shared.getResponse(input: text) { [weak self] response in
            guard let self = self else {
                return
            }
                   
           // Hide the typing indicator (if added)
           
           let botMessage = Message(
               sender: self.chatbot,
               messageId: UUID().uuidString,
               sentDate: Date(),
               kind: .text(response)
           )
           self.messages.append(botMessage)
           
           DispatchQueue.main.async {
               self.messagesCollectionView.reloadData()
               self.messagesCollectionView.scrollToLastItem()
           }
       }
   }
}

extension ChatbotViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 255/255, green: 202/255, blue: 212/255, alpha: 1.0) : UIColor(red: 244/255, green: 172/255, blue: 183/255, alpha: 1.0)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == "self" {
            if let email = Auth.auth().currentUser?.email {
                let avatar = Avatar(image: fetchUserImage(email: email), initials: "")
                avatarView.set(avatar: avatar)
                avatarView.isHidden = isPreviousMessageSameSender(at: indexPath)
            }
        }
        
        else {
            let avatar = Avatar(image: UIImage(named: "Chatbot_Avatar"), initials: "")
            avatarView.set(avatar: avatar)
            avatarView.isHidden = isPreviousMessageSameSender(at: indexPath)
        }
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else {
            return false // No previous message exists
        }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    func fetchUserImage(email: String) -> UIImage {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email MATCHES %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                if let imageData = user.profilePicture as Data?, let image = UIImage(data: imageData) {
                    return image
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
        return UIImage(named: "User_Avatar")!
    }
}

