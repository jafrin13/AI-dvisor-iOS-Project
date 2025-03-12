//
//  JournalCollectionViewCell.swift
//  AI-dvisor
//
//  Created by Johnson, Courtney M on 3/5/25.
//

import UIKit

class JournalCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var journalView: UIView!
    @IBOutlet weak var journalTitle: UILabel!
    @IBOutlet weak var importanceLabel: UILabel!
}

struct Journal {
    let title: String
    let importance: String
    let bgColor: UIColor
}
