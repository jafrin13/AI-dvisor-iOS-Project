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
import PDFKit

class OpenNotebookViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var pdfPreview: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initially hide the preview image
        pdfPreview.isHidden = true
      
    }

    @IBAction func onUploadButtonPressed(_ sender: Any) {
        let documentSelector = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        documentSelector.delegate = self
        // user can only choose 1 file at a time
        documentSelector.allowsMultipleSelection = false
        present(documentSelector, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }

        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(selectedFileURL.lastPathComponent)

        do {
            if FileManager.default.fileExists(atPath: tempFileURL.path) {
                try FileManager.default.removeItem(at: tempFileURL)
            }
            try FileManager.default.copyItem(at: selectedFileURL, to: tempFileURL)

            // Generate thumbnail
            if let thumbnailImage = generateThumbnail(from: tempFileURL) {
                // Show preview image **before** uploading
                DispatchQueue.main.async {
                    self.pdfPreview.image = thumbnailImage
                    self.pdfPreview.isHidden = false
                }
                // Upload PDF and thumbnail
                uploadFileToFirebase(tempFileURL) { pdfURL in
                    self.uploadThumbnailToFirebase(thumbnailImage, pdfURL: pdfURL)
                }
            }

        } catch {
            print("Failed to copy file: \(error.localizedDescription)")
        }
    }

    func generateThumbnail(from pdfURL: URL, size: CGSize = CGSize(width: 150, height: 200)) -> UIImage? {
        guard let pdfDocument = PDFDocument(url: pdfURL),
              let pdfPage = pdfDocument.page(at: 0) else { return nil }

        let pageRect = pdfPage.bounds(for: .mediaBox) // Get full page size
        
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: size)) // Fill background to avoid transparency

            let scale = min(size.width / pageRect.width, size.height / pageRect.height)
            let scaledWidth = pageRect.width * scale
            let scaledHeight = pageRect.height * scale
            let xOffset = (size.width - scaledWidth) / 2
            let yOffset = (size.height - scaledHeight) / 2

            let transform = CGAffineTransform(scaleX: scale, y: -scale) // Fix upside-down issue
                .translatedBy(x: 0, y: -pageRect.height)

            context.cgContext.concatenate(transform)

            pdfPage.draw(with: .mediaBox, to: context.cgContext)
        }
    }


    /// Uploads the PDF file and returns the URL
    func uploadFileToFirebase(_ fileURL: URL, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("uploads/\(UUID().uuidString).pdf")

        let uploadTask = storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let downloadURL = url {
                    print("File uploaded successfully: \(downloadURL.absoluteString)")
                    completion(downloadURL.absoluteString)
                } else {
                    print("Failed to retrieve download URL")
                }
            }
        }
    }

    /// Uploads the thumbnail image to Firebase
    func uploadThumbnailToFirebase(_ image: UIImage, pdfURL: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        let storageRef = Storage.storage().reference().child("thumbnails/\(UUID().uuidString).jpg")

        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Thumbnail upload failed: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let thumbnailURL = url {
                    print("Thumbnail uploaded: \(thumbnailURL.absoluteString)")

                    // Save both URLs to Firestore
                    self.saveFileMetadataToFirestore(pdfURL: pdfURL, thumbnailURL: thumbnailURL.absoluteString)
                } else {
                    print("Failed to retrieve thumbnail URL")
                }
            }
        }
    }

    // Saves metadata (PDF and thumbnail URLs) to Firestore
    func saveFileMetadataToFirestore(pdfURL: String, thumbnailURL: String) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "pdfURL": pdfURL,
            "thumbnailURL": thumbnailURL,
            "timestamp": Timestamp()
        ]

        db.collection("uploads").addDocument(data: data) { error in
            if let error = error {
                print("Failed to save metadata: \(error.localizedDescription)")
            } else {
                print("File metadata saved successfully.")
            }
        }
    }
}

