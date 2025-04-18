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
import PDFKit

class ChatbotViewController: MessagesViewController {
    
    var delegate: UIViewController!
    var folderFilePath: String = "" // path to the folder we want to store any generated content to passed from segue
    var localFileURL: URL? // local cached file retreived from Firebase
    var studyMaterialType: String = "" // type of study material the user wants
    var notesContent: String = "" // stores the contents of the user's notes
    var messages: [Message] = [] // stores the messages in the chat
    let currentUser = Sender(senderId: "self", displayName: "User")
    let chatbot = Sender(senderId: "bot", displayName: "AI-dvisor")
    let defaultMessage: String = "Type message here..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesContent = ""
        setupTopBar()
        messagesCollectionView.contentInset = UIEdgeInsets(top: 163, left: 0, bottom: 0, right: 0) // saves room at the top of the view controller to show back button and title
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.text = defaultMessage
        messageInputBar.inputTextView.textColor = .lightGray
        
        // extracts the text from the user's notes to send to AI and creates the chosen study material
        extractTextAndGenerateContent(fileURL: localFileURL!, materialType: studyMaterialType)
    }
    
    private func setupTopBar() {
        // Create Background View for the Top Bar
        let topBarView = UIView()
        topBarView.backgroundColor = UIColor(red: 255/255.0, green: 229/255.0, blue: 217/255.0, alpha: 1.0) // makes background the custom orange color
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        // Create Back Button
        let backButton = UIButton(type: .system)
        backButton.setTitle("< Back", for: .normal)
        backButton.setTitleColor(UIColor(red: 206/255.0, green: 212/255.0, blue: 179/255.0, alpha: 1.0), for: .normal) // make button color the custom green color
        backButton.titleLabel?.font = UIFont(name: "Marker Felt", size: 32)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside) // add function for when back button is pressed/selected
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        // Create Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Chat"
        titleLabel.textColor = UIColor(red: 157/255.0, green: 129/255.0, blue: 137/255.0, alpha: 1.0) // make label color custom brown color
        titleLabel.font = UIFont(name: "Marker Felt", size: 32)
        titleLabel.textAlignment = .center // centers the text inside the label
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
    
    func extractTextAndGenerateContent(fileURL: URL, materialType: String) {
        // Attempt to create the PDFDocument
        if let document = PDFDocument(url: fileURL) {
            
            // extract text/content from the PDF
            for pageIndex in 0 ..< document.pageCount {
                let page = document.page(at: pageIndex)
                let pageContent = page?.string
                notesContent += pageContent!
            }
        }
        
        // generate the study material the user selected
        if materialType != "none" {
            generateStudyMaterial(materialType: materialType)
        }
    }
    
    func generateStudyMaterial(materialType: String) {
        var prompt = "" // prompt to send to OpenAI
        var materialMade = "" // study material type we are generating
        
        if materialType == "quiz" || materialType == "test" {
            materialMade = "practice_\(materialType)"
            prompt = """
                Please use  mostly the following notes and your additional resources to create a practice \(materialType).
                The notes are: \(notesContent)
            """
        }
        
        else {
            materialMade = "flashcards"
            prompt = """
                Please use  mostly the following notes and your additional resources to create flashcards.
                The notes are: \(notesContent)
            """
        }
        
        // send user's message to OpenAI to get a response and save it as a PDF
        OpenAIConnector.shared.getResponse(prompt: prompt) { response in
            print(response)
            // save new PDF in list of PDFs displayed in the open notebook and reload the notebook view
            if let pdfItem = self.saveTextAsPDF(pdfContent: response, fileName: materialMade) {
                DispatchQueue.main.async {
                    pdfItems.append(pdfItem)
                    globalPdfCollectionView?.reloadData()
                }
            }
        }
        
        // create a new message from the bot to let the user know the material was generated
        let botMessage = Message(
            sender: self.chatbot,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text("Successfully made \(materialMade)!")
        )
        
        // add bot's message to the message array and reload screen
        self.messages.append(botMessage)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
    }
    
    // Code adapted from: https://www.kodeco.com/4023941-creating-a-pdf-in-swift-with-pdfkit
    func saveTextAsPDF(pdfContent: String, fileName: String) -> PDFItem? {
        // Set metadata for the PDF
        let pdfMetaData = [
            kCGPDFContextCreator: "AI-dvisor", // name of app
            kCGPDFContextAuthor: "OpenAI" // author of conent
        ]
        // create a format to configure settings and metadata for the PDF
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        // set page size to 8.5 x 11 (1 inch = 72 points)
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        // set margin to 0.5 inches
        let margin: CGFloat = 0.5 * 72.0

        // create a renderer to draw the PDF content
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        // generate PDF with the given text
        let data = renderer.pdfData { (context) in
            context.beginPage()

            // define font attributes
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]

            // create rectangle inside the margins so we write data within the margins
            let textRect = CGRect(
                x: margin,
                y: margin,
                width: pageWidth - 2 * margin,
                height: pageHeight - 2 * margin
            )

            // draw the text inside the rectangle
            pdfContent.draw(in: textRect, withAttributes: attributes)
        }
        
        // save path to pdf
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pdfURL = documentsPath.appendingPathComponent("\(fileName)").appendingPathExtension("pdf")
        try! data.write(to: pdfURL)

        // Generate thumbnail
        let thumbnail = generateThumbnail(from: pdfURL) ?? UIImage(named: "defaultThumbnail")!
        return PDFItem(thumbnail: thumbnail, fileName: fileName, pdfURL: pdfURL.absoluteString)
    }

    // This method creates a thumbnail for the pdf
    func generateThumbnail(from pdfURL: URL, size: CGSize = CGSize(width: 150, height: 200)) -> UIImage? {
        
        // get pdf and grabs the first page
        guard let pdfDoc = PDFDocument(url: pdfURL),
              let firstPage = pdfDoc.page(at: 0) else { return nil }
        
        // Get page dimensions
        let pageRect = firstPage.bounds(for: .mediaBox)
        
        // found online, this basically creates a  UI Image since obviously a pdf is not an image
        // by nature
        let renderer = UIGraphicsImageRenderer(size: size)
        
        // create a new image
        return renderer.image { context in
            // makes a white rectagle
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: size)) // Fill background to avoid transparency
            
            
            // I got help from chatgpt here to be able to size down the pdf where it fits into the rectangle
            // 1. here we find a scale factor that makes the pdf fit inside the rectangle
            // 2. we can then use it to make the pdf a fraction of its original size
            let scale = min(size.width / pageRect.width, size.height / pageRect.height)
            let scaledWidth = pageRect.width * scale
            let scaledHeight = pageRect.height * scale
            
            // the math for centering is that the left over space is divided into either side so, the contents
            // will still be centered
            let xOffset = (size.width - scaledWidth) / 2
            let yOffset = (size.height - scaledHeight) / 2
            
            // -scale is there to fix upside down issue, then moved up
            // because UI Kit and PDF Kit have diff coordinate systems
            let transform = CGAffineTransform(scaleX: scale, y: -scale)
                .translatedBy(x: 0, y: -pageRect.height)
            
            context.cgContext.concatenate(transform)
            
            firstPage.draw(with: .mediaBox, to: context.cgContext)
        }
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
    // if user starts typing, make default message disappear and set text color to black
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultMessage {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    // if user is done typing/editing, fill text view with default message and make text color gray
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultMessage
            textView.textColor = .lightGray
        }
    }
}

extension ChatbotViewController: InputBarAccessoryViewDelegate {
    
    // called when user presses send button
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // create a new message that contains the user's input
        let newMessage = Message(
            sender: currentSender,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(text)
        )
        
        messages.append(newMessage) // add message to message array
        messagesCollectionView.reloadData() // reload the view to make new message appear
        inputBar.inputTextView.text = "" // clear input bar
        messagesCollectionView.scrollToLastItem() // scroll to the bottom so the new message is visible
        
        // prompt contains the user's notes and their question
        let prompt = """
            Please use  mostly the following notes and your additional resources to answer the given question. 
            The notes are: \(notesContent)
            The question is: \(text)
        """
        
        // send user's message to OpenAI to get a response
        OpenAIConnector.shared.getResponse(prompt: prompt) { response in
            // create a new message with the bot's response
            let botMessage = Message(
                sender: self.chatbot,
                messageId: UUID().uuidString,
                sentDate: Date(),
                kind: .text(response)
            )
            
            // add bot's message to the message array
            self.messages.append(botMessage)
            
            // update the UI on the main thread since network calls happen on a background thread
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        }
    }
}

// in charge of the UI for the Message Display
extension ChatbotViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    // sets colors of text bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        // if the sender is the user make the bubbles light pink, otherise make them dark pink
        return isFromCurrentSender(message: message) ? UIColor(red: 255/255, green: 202/255, blue: 212/255, alpha: 1.0) : UIColor(red: 244/255, green: 172/255, blue: 183/255, alpha: 1.0)
    }
    
    // makes the shape the messages are displayed in a bubble
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    // sets the avatar that displays with different users' messages
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    
        let sender = message.sender // gets the sender of this message (user or chatbot)
        
        // case where user is the sender
        if sender.senderId == "self" {
            // get user's profile picture to use as avatar
            if let email = Auth.auth().currentUser?.email {
                let avatar = Avatar(image: fetchUserImage(email: email), initials: "")
                avatarView.set(avatar: avatar)
                avatarView.isHidden = isPreviousMessageSameSender(at: indexPath) // hide avatar if previous message was sent by the same user
            }
            
            // use default image if error authenticating a user
            else {
                let avatar = Avatar(image: UIImage(named: "User_Avatar"), initials: "")
                avatarView.set(avatar: avatar)
                avatarView.isHidden = isPreviousMessageSameSender(at: indexPath) // hide avatar if previous message was sent by the same user
            }
        }
        
        // case where chatbot is the sender
        else {
            let avatar = Avatar(image: UIImage(named: "Chatbot_Avatar"), initials: "")
            avatarView.set(avatar: avatar)
            avatarView.isHidden = isPreviousMessageSameSender(at: indexPath)
        }
    }
    
    // checks if thie sender of this message is the same as the sender of the previous message
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else {
            return false // No previous message exists
        }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    // get the profile picture for the user that has the given email
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
        return UIImage(named: "User_Avatar")! // use default user avatar if an error occurs 
    }
}

