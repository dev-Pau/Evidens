//
//  Conversation.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/2/22.
//

import CoreData
import UIKit

/// The model for a Conversation.
struct Conversation: Equatable {
    
    let id: String?
    let name: String
    var image: String?
    let userId: String
    var date: Date?
    private(set) var unreadMessages: Int?
    private(set) var isPinned: Bool
    private(set) var latestMessage: Message?
    
    /// Creates an instance of a Conversation.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the instance.
    ///   - name: The name of the user of this conversation.
    ///   - image: The image of the user of this conversation.
    ///   - userId: The unique identifier for the target user. By default, this is set to a generated UUID.
    ///   - unreadMessages: The number of unread messages of this conversation.
    ///   - isPinned: The value of the isPinned for this conversation.
    ///   - date: The creation date of the conversation.
    ///   - latestMessage: The latest Message associated with this conversation.
    init(id: String, name: String, image: String?, userId: String, unreadMessages: Int, isPinned: Bool, date: Date, latestMessage: Message) {
        self.id = id
        self.name = name
        self.image = image
        self.userId = userId
        self.unreadMessages = unreadMessages
        self.isPinned = isPinned
        self.date = date
        self.latestMessage = latestMessage
    }
    
    /// Creates an instance of a new empty Conversation.
    ///
    /// - Parameters:
    ///   - name: The name of the user of this conversation.
    ///   - userId: The unique identifier for the target user. By default, this is set to a generated UUID.
    ///   - ownerId: The unique identifier for the owner user.
    init(name: String, userId: String, ownerId: String) {
        let idArray = [userId, ownerId].sorted()
        self.id = idArray.joined(separator: "_")
        self.name = name
        self.userId = userId
        self.image = nil
        self.unreadMessages = nil
        self.date = nil
        self.isPinned = false
        self.latestMessage = nil
    }
    
    /// Creates an instance of a Conversation.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the conversation.
    ///   - userId: The unique identifier for the user.
    ///   - name: The name of the conversation.
    ///   - date: The date of the conversation.
    ///   - image: The image associated with the conversation.
    init(id: String, userId: String, name: String, date: Date, image: String?) {
        self.id = id
        self.name = name
        self.userId = userId
        self.image = image
        self.date = date
        self.unreadMessages = nil
        self.isPinned = false
        self.latestMessage = nil
    }
    

    /// Creates an instance of Conversation from a Core Data entity.
    ///
    /// - Parameters:
    ///   - entity: The ConversationEntity instance from the Core Data store.
    init?(fromEntity entity: ConversationEntity) {
        self.id = entity.wrappedId
        self.name = entity.wrappedName
        self.image = entity.wrappedImage
        self.userId = entity.wrappedUserId
        self.unreadMessages = entity.unreadMessages
        self.isPinned = entity.isPinned
        self.date = entity.wrappedDate
        self.latestMessage = Message(fromEntity: entity.wrappedLatestMessage)!
    }
    
    /// Creates a ConversationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of ConversationEntity.
    @discardableResult
    func getEntity(context: NSManagedObjectContext) -> ConversationEntity {
        let entity = ConversationEntity(context: context)
        
        entity.id = id
        entity.name = name
        entity.image = image
        entity.date = date
        entity.userId = userId
        entity.isPinned = isPinned
        
        return entity
    }
}

extension Conversation {
    
    /// Finish creating the conversation by updating the conversation properties.
    ///
    /// - Parameters:
    ///   - image: The image associated with the conversation.
    ///   - latestMessage: The first message in the conversation.
    mutating func finishCreatingConversation(image: String?, firstMessage: Message) {
        self.image = image
        self.unreadMessages = 0
        self.isPinned = false
        self.date = Date()
        self.latestMessage = firstMessage
    }
    
    /// Updates the instance's latestMessage property.
    ///
    /// - Parameters:
    ///   - newLatestMessage: The new latestMessage to be updated.
    mutating func changeLatestMessage(to newLatestMessage: Message) {
        latestMessage = newLatestMessage
    }
    
    /// Updates the instance's image property.
    ///
    /// - Parameters:
    ///   - newLatestMessage: The new image to be updated.
    mutating func changeImage(_ image: String) {
        self.image = image
    }
    
    /// Updates the instance's unreadMessages property.
    mutating func markMessagesAsRead() {
        unreadMessages = 0
        latestMessage?.markAsRead()
    }
  
    
    /// Updates the instance's isPinned property.
    mutating func togglePin() {
        isPinned.toggle()
    }
}

extension Conversation {
    
    /// Compare two Conversation objects for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side Conversation object.
    ///   - rhs: The right-hand side Conversation object.
    /// - Returns: True if the Conversation objects have the same id, false otherwise.
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }
}

