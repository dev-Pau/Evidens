//
//  DataService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/23.
//

import CoreData
import Foundation
import UIKit

/// A singleton gateway service used to interface with Core Data.
struct DataService {
    
    static let shared = DataService()
    let managedObjectContext: NSManagedObjectContext
    
    /// Creates an instance of the DataGateway with the managed object context from the AppDelegate.
    init() {
        self.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

// MARK: - Create Operations

extension DataService {
    
    /// Saves a new Conversation to the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be saved.
    ///   - latestMessage: The first Message of the conversation.
    func save(conversation: Conversation, latestMessage: Message) {
        let messageEntity = latestMessage.getEntity(context: managedObjectContext)
        let conversationEntity = conversation.getEntity(context: managedObjectContext)
        messageEntity.conversation = conversationEntity
        conversationEntity.latestMessage = messageEntity
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Saves a new Message to the Core Data store.
    ///
    /// - Parameters:
    ///   - message: The Message to be saved.
    ///   - conversation: The parent Conversation.
    func save(message: Message, to conversation: Conversation) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId == %@", conversation.userId as CVarArg)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            
            if let conversationEntity = conversationEntities.first {
                let messageEntity = message.getEntity(context: managedObjectContext)
                messageEntity.conversation = conversationEntity
                conversationEntity.latestMessage = messageEntity

                try managedObjectContext.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Retrieve Operations

extension DataService {
    
    /// Retrieves all Conversations from the Core Data store.
    ///
    /// - Returns:
    /// An array of saved Conversations.
    func getConversations() -> [Conversation] {
        var conversationEntities = [ConversationEntity]()
        
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        let pinnedSortDescriptor = NSSortDescriptor(key: "isPinned", ascending: false)
        let sentDateSortDescriptor = NSSortDescriptor(key: "latestMessage.sentDate", ascending: false)
        request.sortDescriptors = [pinnedSortDescriptor, sentDateSortDescriptor]
        
        do {
            conversationEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return conversationEntities.compactMap { Conversation(fromEntity: $0) }
    }
    
    /// Retrieves a batch of Messages from the Core Data store.
    /// - Parameters:
    ///   - conversation: The parent Conversation.
    ///
    /// - Returns:
    /// An array of saved Messages.
    func getMessages(for conversation: Conversation) -> [Message] {
        var messageEntities = [MessageEntity]()
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        request.fetchLimit = 40
        request.predicate = NSPredicate(format: "conversation.userId = %@", conversation.userId as CVarArg)
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }

        return messageEntities.compactMap { Message(fromEntity: $0) }.reversed()
    }
    
    func getConversations(for text: String, withLimit limit: Int) -> [Conversation] {
        var conversationEntities = [ConversationEntity]()
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "name CONTAINS[c] %@", text)
        request.fetchLimit = limit

        do {
            conversationEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return conversationEntities.compactMap { Conversation(fromEntity: $0) }
    }
    
    func getMessages(for text: String, withLimit limit: Int) -> [Message] {
        var messageEntities = [MessageEntity]()
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "text CONTAINS[c] %@", text)
        request.fetchLimit = 3
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return messageEntities.compactMap { Message(fromEntity: $0) }
    }
    
    func getConversations(for conversationIds: [String]) -> [Conversation] {
        var conversationEntities = [ConversationEntity]()
        let group = DispatchGroup()
        
        for id in conversationIds {
            group.enter()
            
            let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
            request.predicate = NSPredicate(format: "id = %@", id)
            
            do {
                let entity = try managedObjectContext.fetch(request)
                if let firstEntity = entity.first {
                    conversationEntities.append(firstEntity)
                }

            } catch {
                print(error.localizedDescription)
            }
            
            group.leave()
        }
        
        group.wait()
        
        return conversationEntities.compactMap { Conversation(fromEntity: $0) }
    }
    
    func getMessages(for conversation: Conversation, around message: Message) -> [Message] {
        var messageEntities = [MessageEntity]()

        let newerRequest = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        newerRequest.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        newerRequest.fetchLimit = 10
        newerRequest.predicate = NSPredicate(format: "conversation.userId = %@ AND sentDate <= %@", conversation.userId as CVarArg, message.sentDate as NSDate)
        
        let olderRequest = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        olderRequest.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        olderRequest.fetchLimit = 10
        olderRequest.predicate = NSPredicate(format: "conversation.userId = %@ AND sentDate > %@", conversation.userId as CVarArg, message.sentDate as NSDate)

        do {
            messageEntities = try managedObjectContext.fetch(newerRequest)
            let olderEntities = try managedObjectContext.fetch(olderRequest)
            messageEntities.append(contentsOf: olderEntities)

        } catch {
            print(error.localizedDescription)
        }

        let messages = messageEntities.compactMap { Message(fromEntity: $0) }
        return messages.sorted(by: { $0.sentDate < $1.sentDate })
    }
    
    func getUnreadMessage() -> Int {
        let request: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "MessageEntity")
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "isRead == %@", NSNumber(value: false))
        
        do {
            let result = try managedObjectContext.fetch(request)
            if let count = result.first?.intValue {
                return count
            } else {
                return 0
            }
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
}

// MARK: - Update Operations

extension DataService {
    
    func editPhase() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "phase = %@ AND senderId = %@", NSNumber(value: MessagePhase.sending.rawValue), uid)
        
        do {
            let messages = try managedObjectContext.fetch(request)
            for message in messages {
                message.setValue(MessagePhase.failed.rawValue, forKey: "phase")
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Updates a given property for a given Conversation within the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be updated.
    ///   - value: The new value to be set.
    ///   - key: The key of the property to be updated.
    func edit(conversation: Conversation, set value: Any?, forKey key: String) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId = %@", conversation.userId as CVarArg)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            if let conversationEntity = conversationEntities.first {
                conversationEntity.setValue(value, forKey: key)
            }
            try managedObjectContext.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func edit(message: Message, set value: Any?, forKey key: String) {
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "messageId = %@", message.messageId)
        
        do {
            let messageEntities = try managedObjectContext.fetch(request)
            if let messageEntity = messageEntities.first {
                messageEntity.setValue(value, forKey: key)
            }
            
            try managedObjectContext.save()            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Updates all isRead messages properties for a given Conversation within the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be updated.
    func readMessages(conversation: Conversation) {
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "conversation.userId = %@ AND isRead = false", conversation.userId as CVarArg)
        
        do {
            let messages = try managedObjectContext.fetch(request)
            for message in messages {
                message.setValue(true, forKey: "isRead")
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Delete Operations

extension DataService {
    
    /// Deletes a given Conversation from the Core Data store.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation to be deleted.
    func delete(conversation: Conversation) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId = %@", conversation.userId as CVarArg)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            
            if let conversationEntity = conversationEntities.first {
                managedObjectContext.delete(conversationEntity)
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(message: Message) {
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "messageId = %@", message.messageId)
        
        do {
            let messageEntities = try managedObjectContext.fetch(request)
            if let messageEntity = messageEntities.first {
                managedObjectContext.delete(messageEntity)
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Miscellaneous

extension DataService {
    
    func conversationExists(for id: String, completion: @escaping(Bool) -> Void) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId == %@", id)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            
            if let _ = conversationEntities.first {
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
