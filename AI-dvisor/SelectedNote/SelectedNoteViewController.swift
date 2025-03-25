//
//  SelectedNoteViewController.swift
//  AI-dvisor
//
//  Created by Mac Laptop on 3/3/25.
//

import UIKit
import PDFKit
import FirebaseStorage
import FirebaseFirestore

class SelectedNoteViewController: UIViewController {

    @IBOutlet weak var noteTitle: UILabel! // title of note displayed on the screen
    @IBOutlet weak var noteView: UIView! // view to display the actual document
    @IBOutlet weak var optionsView: UIView! // view for generative options
    
    var passedNoteTitle: String = "" // title of the displayed note passed from segue
    var noteFilePath: String = "" // path to the doc we want to display in Firebase passed from segue
    var folderFilePath: String = "" // path to the folder we want to store any generated content to passed from segue
    var localFileURL: URL? // local cached file retreived from Firebase
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update label to the name/title of the selected note
        noteTitle.text = passedNoteTitle
                
        // make the options view heigh 0 so it doesn't show
        optionsView.frame.size.height = 0
        
        // make corners of the options view rounded
        optionsView.layer.cornerRadius = 20
        
        // locally download the file and fill UIView with the selected note
        // downloadFileFromFirebase(filePath: noteFilePath)
    }
    
//    func downloadFileFromFirebase(filePath: String) {
//        let storageRef = Storage.storage().reference()
//        let fileRef = storageRef.child(filePath)
//        let localURL = FileManager.default.temporaryDirectory.tempDirectoryURL.appendingPathComponent(passedNoteTitle)
//
//        fileRef.write(toFile: localURL) { url, error in
//            if let error = error {
//                print("Error downloading file: \(error.localizedDescription)")
//            } else {
//                self.localFileURL = localURL
//                self.displayDocument()
//            }
//        }
//    }
//    
//    func displayDocument() {
//        guard let localFileURL = localFileURL else { return }
//        
//        // Initialize PDFView and set up the document
//        let pdfView = PDFView(frame: noteView.bounds)
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        pdf.autoScales = true
//        pdfView.document = PDFDocument(url: localFileURL)
//        
//        // Add the PDF view as a subview to noteView
//        noteView.addSubview(pdfView)
//    }
    
    @IBAction func pressedGenerateButton(_ sender: Any) {
        // make options view pop up
        UIView.animate(withDuration: 0.6) {
            self.optionsView.frame.size.height = 355
            self.view.layoutIfNeeded()
        }
    }
    

    @IBAction func dragViewDown(_ sender: UIPanGestureRecognizer) {
        guard let piece = sender.view else {
            return
        }
        
        let maxHeight: CGFloat = 355
        let minHeight: CGFloat = 0
        var initialHeight: CGFloat = 0
        let translation = sender.translation(in: piece.superview)
        
        if sender.state == .began {
            initialHeight = piece.frame.origin.y
        }
        
        if sender.state == .changed {
            let newHeight = initialHeight - translation.y
            let boundedHeight = min(maxHeight, max(minHeight, newHeight))
            piece.frame.origin.y = boundedHeight
        }
        
        if sender.state == .ended {
            let middleHeight: CGFloat = (maxHeight +
                                         minHeight) / 2
            let targetHeight = self.optionsView.frame.size.height > middleHeight ? maxHeight : minHeight

            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                piece.frame.origin.y = targetHeight
            })
        }
    }
    
    @IBAction func pressedQuizButton(_ sender: Any) {
        performSegue(withIdentifier: "toChatbotSegue", sender: "quiz")
    }
    
    @IBAction func pressedTestButton(_ sender: Any) {
        performSegue(withIdentifier: "toChatbotSegue", sender: "test")
    }
    
    @IBAction func pressedFlashcardsButton(_ sender: Any) {
        performSegue(withIdentifier: "toChatbotSegue", sender: "flashcards")
    }
    
    @IBAction func pressedTalkToChatButton(_ sender: Any) {
        performSegue(withIdentifier: "toChatbotSegue", sender: "none")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatbotSegue", let chatbotVC = segue.destination as? ChatbotViewController {
            chatbotVC.noteFilePath = self.noteFilePath
            chatbotVC.folderFilePath = self.folderFilePath
            chatbotVC.localFileURL = self.localFileURL
            chatbotVC.delegate = self
            
            if let materialType = sender as? String {
                chatbotVC.studyMaterialType = materialType
            }
            
//            else {
//                chatbotVC.studyMaterialType = nil
//            }
        }
    }
}
