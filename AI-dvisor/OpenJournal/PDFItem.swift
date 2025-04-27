//
//  PDFItem.swift
//  AI-dvisor
//
//  Created by Lauren Leyendecker on 4/20/25.
//

import UIKit
import Foundation

class PDFItem {
    var thumbnail: UIImage
    var fileName: String
    var pdfURL: String
    var filePath: String

    init(thumbnail: UIImage, fileName: String, pdfURL: String, filePath: String) {
        self.thumbnail = thumbnail
        self.fileName = fileName
        self.pdfURL = pdfURL
        self.filePath = filePath
    }
}
