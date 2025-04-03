//
//  Sender.swift
//  AI-dvisor
//
//  Created by Mac Laptop on 3/7/25.
//

import MessageKit

class Sender: SenderType {
    var senderId: String
    var displayName: String

    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
