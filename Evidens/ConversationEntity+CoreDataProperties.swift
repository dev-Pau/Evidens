//
//  ConversationEntity+CoreDataProperties.swift
//  
//
//  Created by Pau Fernández Solà on 20/5/23.
//
//

import Foundation
import CoreData


extension ConversationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationEntity> {
        return NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
    }

    @NSManaged public var image: String?
    @NSManaged public var isPinned: Bool
    @NSManaged public var name: String?
    @NSManaged public var userId: UUID?
    @NSManaged public var conversationId: String?
    @NSManaged public var messages: NSSet?
    @NSManaged public var latestMessage: MessageEntity?
    
    var wrappedName: String {
        name ?? "Undefined"
    }
    
    var wrappedConversationId: String {
        conversationId ?? UUID().uuidString
    }
    
    var wrappedUserId: UUID {
        userId ?? UUID()
    }
}

// MARK: Generated accessors for messages
extension ConversationEntity {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageEntity)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageEntity)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
