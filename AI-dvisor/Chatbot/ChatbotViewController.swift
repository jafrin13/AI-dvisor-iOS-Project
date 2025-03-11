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
        
        // save room for the top of the VC (can change value if too much or too little)
       // messagesCollectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.text = defaultMessage
        messageInputBar.inputTextView.textColor = .lightGray
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

extension ChatbotViewController {
    func receiveBotResponse(to userMessage: String) {
        let botReplyText = generateBotResponse(for: userMessage)
        let botMessage = Message(
            sender: chatbot,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(botReplyText)
        )

        // Simulate a delay for bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.append(botMessage)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func generateBotResponse(for message: String) -> String {
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("hello") {
            return "Hello! How can I assist you today? 😊"
        } else if lowercasedMessage.contains("what is a viewcontroller") {
            return "A ViewController (VC) is responsible for managing a screen in your iOS app!"
        } else {
            return "I'm still learning! Try asking me something else. 🤖"
        }
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
