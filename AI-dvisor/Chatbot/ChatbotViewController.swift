//
//  ChatbotViewController.swift
//  AI-dvisor
//
//  Created by Mac Laptop on 3/3/25.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatbotViewController: MessagesViewController {
    
    var delegate: UIViewController!
    var noteFilePath: String = "" // path to the doc we want to display in Firebase passed from segue
    var folderFilePath: String = "" // path to the folder we want to store any generated content to passed from segue
    var localFileURL: URL? // local cached file retreived from Firebase
    var studyMaterialType: String = ""
    
    var messages: [Message] = [] // stores the messages in the chat
    let currentUser = Sender(senderId: "self", displayName: "User") // could change display name to username
    let chatbot = Sender(senderId: "bot", displayName: "AI-dvisor")
    let defaultMessage: String = "Type message here..."

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        // save room for the top of the VC (can change value if too much or too little)
        messagesCollectionView.contentInset = UIEdgeInsets(top: 163, left: 0, bottom: 0, right: 0)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.text = defaultMessage
        messageInputBar.inputTextView.textColor = .lightGray
    }
    
    private func setupTopBar() {
        // Create Background View for the Top Bar
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255/255.0, green: 229/255.0, blue: 217/255.0, alpha: 1.0)
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        // Create Back Button
        let backButton = UIButton(type: .system)
        backButton.setTitle("< Back", for: .normal)
        backButton.setTitleColor(UIColor(red: 206/255.0, green: 212/255.0, blue: 179/255.0, alpha: 1.0), for: .normal)
        backButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 32)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        // Create Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Chat"
        titleLabel.textColor = UIColor(red: 157/255.0, green: 129/255.0, blue: 137/255.0, alpha: 1.0)
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
        // Create a new message when the send button is pressed
        let newMessage = Message(
            sender: currentSender,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(text)
        )
        
        // Append the new message to the array
        messages.append(newMessage)
        
        // Reload the data to update the message list
        messagesCollectionView.reloadData()
        
        // Clear the input text after sending
        inputBar.inputTextView.text = ""
        
        // Scroll to the last item (latest message)
        messagesCollectionView.scrollToLastItem()
    }
}

extension ChatbotViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.systemPink.withAlphaComponent(0.7) : UIColor.systemPink.withAlphaComponent(1.0)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}
