//
//  OpenNotebookViewController.swift
//  AI-dvisor
//
//  Created by Nguyen, Stephanie V on 3/5/25.
//

import UIKit
import UniformTypeIdentifiers
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class OpenNotebookViewController: UIViewController, UIDocumentPickerDelegate {

    // @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onUploadButtonPressed(_ sender: Any) {
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
               documentPicker.delegate = self
               documentPicker.allowsMultipleSelection = false
               present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        print("Selected File URL: \(selectedFileURL.path)")
        
        // Copy the file to a temp location
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(selectedFileURL.lastPathComponent)

        do {
            if FileManager.default.fileExists(atPath: tempFileURL.path) {
                try FileManager.default.removeItem(at: tempFileURL) // Remove existing temp file
            }
            try FileManager.default.copyItem(at: selectedFileURL, to: tempFileURL)
            print("File copied to: \(tempFileURL.path)")
            uploadFileToFirebase(tempFileURL) // Upload the copied file
        } catch {
            print("Failed to copy file: \(error.localizedDescription)")
        }
    }

    
    
    func uploadFileToFirebase(_ fileURL: URL) {
        print("Uploading file from: \(fileURL.path)")

        do {
            // Convert file to Data
            let fileData = try Data(contentsOf: fileURL)
            
            // Create Firebase Storage reference
            let storageRef = Storage.storage().reference().child("uploads/\(UUID().uuidString).\(fileURL.pathExtension)")
            
            // Upload file data
            let uploadTask = storageRef.putData(fileData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Upload failed: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        print("File uploaded successfully: \(downloadURL.absoluteString)")
                        
                        // Save metadata to Firestore
                        self.saveFileMetadataToFirestore(url: downloadURL.absoluteString, fileName: fileURL.lastPathComponent)
                    } else {
                        print("Failed to retrieve download URL")
                    }
                }
            }

            // Track Upload Progress
            uploadTask.observe(.progress) { snapshot in
                if let progress = snapshot.progress {
                    let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    print(" Upload progress: \(percentComplete)%")
                }
            }
        } catch {
            print(" Failed to read file data: \(error.localizedDescription)")
        }
    }

    
    
    
    func saveFileMetadataToFirestore(url: String, fileName: String) {
           let db = Firestore.firestore()
           let data: [String: Any] = ["fileName": fileName, "url": url, "timestamp": Timestamp()]
           
           db.collection("uploads").addDocument(data: data) { error in
               if let error = error {
                   print("Failed to save metadata: \(error.localizedDescription)")
               } else {
                   print("File metadata saved successfully.")
               }
           }
       }
    
    
        /* func showImagePreview(from fileURL: URL) {
            DispatchQueue.main.async {
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    self.previewImageView.image = image
                   self.previewImageView.isHidden = false
                }
            }
        }
        */
 
    
    
    
    

}
