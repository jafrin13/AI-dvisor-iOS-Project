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

    init(thumbnail: UIImage, fileName: String, pdfURL: String) {
        self.thumbnail = thumbnail
        self.fileName = fileName
        self.pdfURL = pdfURL
    }
}
