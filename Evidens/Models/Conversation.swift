//
//  Conversation.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/2/22.
//

import UIKit

struct Conversation {
    let id: String
    let name: String
    let otherUserUid: String
    let creationDate: TimeInterval
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: TimeInterval
    let text: String
    let isRead: Bool
    let senderUid: String
}
