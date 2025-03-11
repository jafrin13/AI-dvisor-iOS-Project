//
//  Message.swift
//  AI-dvisor
//
//  Created by Mac Laptop on 3/7/25.
//

import MessageKit
import Foundation

class Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}
