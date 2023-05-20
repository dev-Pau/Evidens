//
//  MessageEntity+CoreDataProperties.swift
//  
//
//  Created by Pau Fernández Solà on 20/5/23.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var image: String?
    @NSManaged public var isRead: Bool
    @NSManaged public var senderId: String?
    @NSManaged public var kind: Int16
    @NSManaged public var messageId: UUID?
    @NSManaged public var sentDate: Date?
    @NSManaged public var text: String?
    @NSManaged public var conversation: ConversationEntity?
    @NSManaged public var relationship: ConversationEntity?
    
    
}
