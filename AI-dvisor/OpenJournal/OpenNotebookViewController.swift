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


struct PDFItem {
    let thumbnail: UIImage
    let fileName: String
    let pdfURL: String
}

class OpenNotebookViewController: UIViewController, UIDocumentPickerDelegate,  UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var subjectLabel: UILabel!
    var journalTitle: String?
    
    @IBOutlet weak var homeBackButton: UIImageView!

    @IBOutlet weak var pdfCollectionView: UICollectionView!
    
    var pdfItems: [PDFItem] = []

    
        override func viewDidLoad() {
            super.viewDidLoad()
            loadUploadedPDFs()
            pdfCollectionView.delegate = self
            pdfCollectionView.dataSource = self
            
            subjectLabel.text = journalTitle

           
            // Do any additional setup after loading the view.
            let homeScreenGesture = UITapGestureRecognizer(target: self, action: #selector(homeBackImageTapped(_:)))
            
            homeBackButton.addGestureRecognizer(homeScreenGesture)
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PDFCell", for: indexPath) as! PDFCollectionViewCell
        let pdfItem = pdfItems[indexPath.row]
        cell.pdfThumbnailImageView.image = pdfItem.thumbnail
        cell.pdfName.text = pdfItem.fileName
        return cell
    }

    
    
    func loadUploadedPDFs() {
        let db = Firestore.firestore()
        db.collection("uploads").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching PDFs: \(error.localizedDescription)")
                return
            }
            
            // Clear the array before loading new data
            self.pdfItems.removeAll()
            
            guard let documents = snapshot?.documents else { return }
            for doc in documents {
                // Retrieve the file name (if not available, default to "Unknown.pdf")
                let fileName = doc.data()["fileName"] as? String ?? "Unknown.pdf"
                let pdfURL = doc.data()["pdfURL"] as? String ?? ""
    
                if let thumbnailURLString = doc.data()["thumbnailURL"] as? String,
                   let url = URL(string: thumbnailURLString) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            
                            DispatchQueue.main.async {
                                
                                let pdfItem = PDFItem(thumbnail: image, fileName: fileName, pdfURL:pdfURL)
                                self.pdfItems.append(pdfItem)
                                self.pdfCollectionView.reloadData()
                            }
                        }
                    }.resume()
                }
            }
        }
    }



        
        @IBAction func onUploadButtonPressed(_ sender: Any) {
            let documentSelector = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
            // delegate should call document picker
            documentSelector.delegate = self
            // user can only choose 1 file at a time
            documentSelector.allowsMultipleSelection = false
            present(documentSelector, animated: true, completion: nil)
        }
        
        
        
        
        @objc func homeBackImageTapped(_ sender: UITapGestureRecognizer) {
            print("Going back to homepage")
            let storyboard = UIStoryboard(name: "HomeScreenStoryboard", bundle: nil)
            if let backHomeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreen") as? HomeScreenViewController {
                backHomeVC.modalTransitionStyle = .crossDissolve
                backHomeVC.modalPresentationStyle = .fullScreen
                self.present(backHomeVC, animated: true, completion: nil)
            }
        }
        
        
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // make sure there is a selected file
        guard let selectedFile = urls.first else { return }
        
        // we have to make a copy because documentPickerViewController only has read permissions
        // 1. get into a temporary directory to store our file
        // 2. add our file url to that directory to create the path
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent(selectedFile.lastPathComponent)
        
        // make sure theres no duplicate of the file name and now we can copy the item
        // into the temp directory
        do {
            if FileManager.default.fileExists(atPath: tempFileURL.path) {
                try FileManager.default.removeItem(at: tempFileURL)
            }
            try FileManager.default.copyItem(at: selectedFile, to: tempFileURL)
            
            // call our method to make a thumnail
            if let thumbnail = generateThumbnail(from: tempFileURL) {
                let fileName = selectedFile.lastPathComponent
                // I found this online, we want the visual updates to happen on the main thread
                // so we can update the image here and now show the image, this is hard coded
                // for now, just to show the image is uploaded to firebase. In the future I will
                // do a collection view to dynamically present the pdfs.
                
                // Upload PDF and once finished, upload the thumbnail
                uploadFileToFirebase(tempFileURL) { pdfURL in
                    self.uploadThumbnailToFirebase(thumbnail, pdfURL: pdfURL, fileName: fileName)
                    
                    let pdfItem = PDFItem(thumbnail: thumbnail, fileName: fileName, pdfURL: pdfURL)
                    DispatchQueue.main.async {
                        self.pdfItems.append(pdfItem)
                        self.pdfCollectionView.reloadData()
                    }
                }
            }
        } catch {
            print("Failed copying file: \(error.localizedDescription)")
        }
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
        
        
        // Uploads the PDF file and returns the URL
        func uploadFileToFirebase(_ fileURL: URL, completion: @escaping (String) -> Void) {
            
            // grabs the reference of the firebase storage
            // then generates a unique name for the file under "uploads"
            let storageRef = Storage.storage().reference().child("uploads/\(UUID().uuidString).pdf")
            
            let uploadPDF = storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("PDF upload to firebase failed: \(error.localizedDescription)")
                    return
                }
                
                // for now we don't need the url of the pdf but I have the method return
                // the file url just in case we need it for dynamically creating the multiple thumbnails
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
        
        // Uploads the thumbnail image to Firebase
    func uploadThumbnailToFirebase(_ image: UIImage, pdfURL: String, fileName: String) {
            
            // we compress to upload to firebase faster, 70% is apparently a
            // good balance between quality and size
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
            
            let storageRef = Storage.storage().reference().child("thumbnails/\(UUID().uuidString).jpg")
            
            let uploadThumbnail = storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Thumbnail upload to firebase failed: \(error.localizedDescription)")
                    return
                }
                
                
                // also just in case again if I need to grab the image again
                storageRef.downloadURL { url, error in
                    if let thumbnailURL = url {
                        print("Thumbnail uploaded: \(thumbnailURL.absoluteString)")
                        
                        // save both URLs to firestore
                        self.saveFileMetadataToFirestore(pdfURL: pdfURL, thumbnailURL: thumbnailURL.absoluteString, fileName: fileName)
                    } else {
                        print("Failed to get thumbnail URL")
                    }
                }
            }
        }
        
        // Sets up schema (I don't know if its correct but I was
        // searching and it said I can only control the schema through code and not the
        // firebase console)
    func saveFileMetadataToFirestore(pdfURL: String, thumbnailURL: String, fileName: String) {
            let db = Firestore.firestore()
            let data: [String: Any] = [
                "pdfURL": pdfURL,
                "thumbnailURL": thumbnailURL,
                "fileName": fileName
            ]
            
            db.collection("uploads").addDocument(data: data) { error in
                if let error = error {
                    print("Failed to save metadata: \(error.localizedDescription)")
                } else {
                    print("File metadata saved successfully.")
                }
            }
        }
    
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedPDF = pdfItems[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Lauren_Storyboard", bundle: nil)
            if let selectedNoteVC = storyboard.instantiateViewController(withIdentifier: "SelectedNoteVC") as? SelectedNoteViewController {
                
                selectedNoteVC.passedNoteTitle = selectedPDF.fileName
                selectedNoteVC.noteFilePath = getPathFromURL(selectedPDF.pdfURL) // Helper below
                selectedNoteVC.folderFilePath = "generated/\(selectedPDF.fileName)" // Customize as needed
                
                self.present(selectedNoteVC, animated: true, completion: nil)
            }
        }

    }

func getPathFromURL(_ fullURL: String) -> String {
    // Firebase URLs are like: https://firebasestorage.googleapis.com/v0/b/YOUR_APP/o/uploads%2Fabc123.pdf?alt=media...
    // We want: uploads/abc123.pdf
    if let range = fullURL.range(of: "/o/") {
        let pathPart = fullURL[range.upperBound...]
        if let endIndex = pathPart.firstIndex(of: "?") {
            let encodedPath = pathPart[..<endIndex]
            let decodedPath = encodedPath.replacingOccurrences(of: "%2F", with: "/")
            return String(decodedPath)
        }
    }
    return ""
}

    

