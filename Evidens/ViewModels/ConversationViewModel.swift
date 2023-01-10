//
//  ConversationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/9/22.
//

import UIKit

struct ConversationViewModel {
    
    var conversation: Conversation
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    var isMessageRead: Bool {
        return conversation.latestMessage.isRead
    }
    
    var messageText: String {
        let message = conversation.latestMessage.text
        
        if message.contains("https://firebasestorage.googleapis.com") {
            //Is a photo or video
            if message.contains("message_images") {
                return "Sent a photo"
            } else {
                return "Sent a video"
            }
        } else {
            //It is a normal messag
            return message
        }
    }
    
    var latestMessageText: String {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return "" }
        if conversation.latestMessage.senderUid == uid {
            return "You: \(messageText)"
        }
        return messageText
    }
    
    func makeAttributed() -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: messageText, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            return attributedString
    }
     
    
    var timestampString: String? {
        
        let timeInterval = conversation.latestMessage.date
        
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.day, .hour, .minute, .second]

        let date = Date(timeIntervalSince1970: timeInterval)

        return formatter.string(from: date, to: Date())
    }
    
    func messageToDisplay() -> NSAttributedString {
        if !isMessageRead {
            let attributedString = NSMutableAttributedString(string: latestMessageText, attributes: [.font: UIFont.boldSystemFont(ofSize: 15), .foregroundColor: UIColor.label])
            attributedString.append(NSAttributedString(string: " · " + timestampString!, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.secondaryLabel]))
            return attributedString
        } else {
            let attributedString = NSMutableAttributedString(string: latestMessageText, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.secondaryLabel])
            attributedString.append(NSAttributedString(string: " · " + timestampString!, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.secondaryLabel]))
            return attributedString
        }
    }
}
