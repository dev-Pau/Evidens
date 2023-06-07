//
//  Chat.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/22.
//

import Foundation
import MessageKit
import CoreData
import Firebase

/// The model for a Message.
struct Message {
    
    let text: String
    let sentDate: Date
    let messageId: String
    let image: String?
    private(set) var isRead: Bool
    let senderId: String
    let kind: MessageKind
    private(set) var phase: MessagePhase
    private(set) var conversationId: String?
    
    /// Creates an instance of a Message.
    ///
    /// - Parameters:
    ///   - text: The raw, user-inputted title of the message.
    ///   - sentDate: The sent date of the message.
    ///   - messageId: The unique identifier for the instance. By default, this is set to a generated UUID.
    ///   - isRead: The value of the isRead for this conversation.
    ///   - senderId: The unique identifier for the sender.
    ///   - image: The raw directory string directory of the image.
    ///   - kind: The associated kind of the message.
    ///   - phase: The associated phase of the message.
    init(text: String, sentDate: Date, messageId: String, isRead: Bool, senderId: String, image: String? = nil, kind: MessageKind, phase: MessagePhase) {
        self.text = text
        self.sentDate = sentDate
        self.messageId = messageId
        self.isRead = isRead
        self.senderId = senderId
        self.image = image
        self.kind = kind
        self.phase = phase
    }
    
    /// Creates an instance of a Message using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary containing the message information.
    ///   - messageId: The unique identifier for the message.
    init(dictionary: [String: Any], messageId: String) {
        self.text = dictionary["text"] as? String ?? "Unknown"
        self.sentDate = Date(timeIntervalSince1970: dictionary["date"] as? TimeInterval ?? 0)
        self.messageId = messageId
        self.isRead = false
        self.senderId = dictionary["senderId"] as? String ?? "Unknown"
        self.image = nil
        self.kind = MessageKind(rawValue: dictionary["kind"] as? Int16 ?? 0) ?? .text
        self.phase = MessagePhase.unread
    }
    
    /// Creates an instance of Message from a Core Data entity.
    ///
    /// - Parameters:
    ///   - entity: The MessageEntity instance from the Core Data store.
    init?(fromEntity entity: MessageEntity) {
        self.text = entity.wrappedText
        self.sentDate = entity.wrappedSentDate
        self.messageId = entity.wrappedMessageId
        self.isRead = entity.isRead
        self.senderId = entity.wrappedSenderId
        self.image = entity.image ?? nil
        self.kind = MessageKind(rawValue: entity.kind)!
        self.phase = MessagePhase(rawValue: entity.phase)!
        self.conversationId = entity.conversation?.wrappedId ?? nil
    }
    
    /// Creates a MessageEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of MessageEntity.
    @discardableResult
    func getEntity(context: NSManagedObjectContext) -> MessageEntity {
        let entity = MessageEntity(context: context)
        
        entity.text = text
        entity.sentDate = sentDate
        entity.messageId = messageId
        entity.isRead = isRead
        entity.senderId = senderId
        entity.image = image
        entity.kind = kind.rawValue
        entity.phase = phase.rawValue

        return entity
    }
    
    /// Updates the instance's isRead property.
    mutating func updatePhase(_ phase: MessagePhase) {
        self.phase = phase
    }
    
    /// Updates the instance's isRead property.
    mutating func markAsRead() {
        isRead = true
    }
}
