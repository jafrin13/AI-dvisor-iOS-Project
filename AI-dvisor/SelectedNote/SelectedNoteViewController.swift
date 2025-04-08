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
                
        // hide options view
        let targetHeight: CGFloat = 0
        optionsView.frame.size.height = targetHeight
        optionsView.frame.origin.y = self.view.frame.height
        
        // make corners of the options view rounded
        optionsView.layer.cornerRadius = 35


        
        // locally download the file and fill UIView with the selected note
         downloadFileFromFirebase(filePath: noteFilePath)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("noteView frame: \(noteView.frame)")
        print("optionsView frame: \(optionsView.frame)")
    }
    
    func downloadFileFromFirebase(filePath: String) {
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(filePath)
        let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(passedNoteTitle)

        fileRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("Error downloading file: \(error.localizedDescription)")
            } else {
                print("File downloaded to: \(localURL)")
                self.localFileURL = localURL
                DispatchQueue.main.async {
                    self.displayDocument()
                }
            }
        }
    }
    
    func displayDocument() {
        guard let localFileURL = localFileURL else {
            print("localFileURL is nil")
            return
        }
        
        // Attempt to create the PDFDocument
        guard let document = PDFDocument(url: localFileURL) else {
            print("Failed to create PDFDocument from URL: \(localFileURL)")
            return
        }
        
        // Initialize PDFView and set up the document
        let pdfView = PDFView(frame: noteView.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        pdfView.document = document
        
        // Add the PDF view as a subview to noteView
        noteView.addSubview(pdfView)
        print("PDFView added to noteView")
    }

    @IBAction func pressedGenerateButton(_ sender: Any) {
        // make options view pop up
        let targetHeight: CGFloat = 355
        UIView.animate(withDuration: 0.6, animations: {
            self.optionsView.frame.origin.y = self.view.frame.height - targetHeight
            self.optionsView.frame.size.height = targetHeight
        })
    }
    
    @IBAction func dragViewDown(_ sender: UIPanGestureRecognizer) {
        guard let piece = sender.view else {
            return
        }
            
        let maxHeight: CGFloat = 355
        let minHeight: CGFloat = 0
        let translation = sender.translation(in: piece.superview)

        if sender.state == .changed {
            let newHeight = optionsView.frame.size.height - translation.y
            let boundedHeight = min(maxHeight, max(minHeight, newHeight))
            
            let delta = optionsView.frame.size.height - boundedHeight
            optionsView.frame.origin.y += delta
            optionsView.frame.size.height = boundedHeight
            sender.setTranslation(.zero, in: piece.superview)
        }
        
        if sender.state == .ended {
            let middleHeight: CGFloat = (maxHeight + minHeight) / 2
            let targetHeight = optionsView.frame.size.height > middleHeight ? maxHeight : minHeight
            let delta = optionsView.frame.size.height - targetHeight

            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.optionsView.frame.origin.y += delta
                self.optionsView.frame.size.height = targetHeight
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
        }
    }
}
