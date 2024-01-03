//
//  DataService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/5/23.
//

import CoreData
import Foundation
import UIKit

/// Manager object to interface with CoreData.
class CoreDataManager: CoreDataStackManager {
    
    static let shared = CoreDataManager()
    
    private(set) var coordinators: [String: NSPersistentContainer] = [:]
    
    /// Sets up a Core Data stack for a specific user.
    ///
    /// - Parameters:
    ///    - userId: The unique identifier of the user for whom the Core Data stack is being set up.
    func setupCoordinator(forUserId userId: String) {
        let container = NSPersistentContainer(name: "DataModel")
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(userId).sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        
        coordinators[userId] = container
    }
    
    /// Returns the NSPersistentContainer associated with a specific user.
    ///
    /// - Parameters:
    ///   -  userId: The unique identifier of the user.
    /// - Returns:
    /// The NSPersistentContainer instance for the given user, or `nil` if not found.
    func coordinator(forUserId userId: String) -> NSPersistentContainer? {
        return coordinators[userId]
    }
    
    /// Resets the coordinator by removing all stored coordinators.
    func reset() {
        coordinators.removeAll()
    }
}

/// Manager object to interface with CoreData.
class DataService {
    
    static let shared = DataService()

    private init() { }
    
    var mockManagedObjectContext: NSManagedObjectContext?
    
    var managedObjectContext: NSManagedObjectContext {
        if let mockManagedObjectContext {
            return mockManagedObjectContext
        } else {
            let uid = UserDefaults.standard.value(forKey: "uid") as! String
            return DataService.shared.managedObjectContext(forUserId: uid)!
        }
    }
    
    /// Initializes the coordinator for the specified user ID.
    /// - Parameter userId: The user ID for which the coordinator needs to be set up.
    func initialize(userId: String) {
        CoreDataManager.shared.setupCoordinator(forUserId: userId)
    }
    
    /// Resets the coordinator by removing all stored coordinators.
    func reset() {
        CoreDataManager.shared.reset()
    }
    
    /// Retrieves the managed object context associated with the specified user ID.
    /// - Parameter userId: The user ID for which the managed object context is needed.
    /// - Returns: The managed object context for the specified user ID, or `nil` if not found.
    func managedObjectContext(forUserId userId: String) -> NSManagedObjectContext? {
        return CoreDataManager.shared.coordinator(forUserId: userId)?.viewContext
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
    
    /// Saves a new Message to the Core Data store associated with a specific conversation ID.
    ///
    /// - Parameters:
    ///   - message: The Message to be saved.
    ///   - conversationId: The ID of the parent Conversation.
    func save(message: Message, to conversationId: String) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "id == %@", conversationId)
        
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
    
    /// Saves a notification to the Core Data storage based on its kind.
    /// - Parameter notification: The notification to be saved.
    func save(notification: Notification) {
        
        switch notification.kind {
            
        case .likePost:
            
            let _ = notification.getPostLikeEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }

        case .likeCase:
            let _ = notification.getCaseLikeEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
            
        case .connectionRequest:
            let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
            request.predicate = NSPredicate(format: "uid == %@ AND kind == %@", notification.uid as CVarArg, NSNumber(value: notification.kind.rawValue))
            
            do {
                let existingNotifications = try managedObjectContext.fetch(request)

                if let existingNotification = existingNotifications.first {
                    // Update the existing notification
                    existingNotification.setValue(notification.timestamp, forKey: "timestamp")
                    existingNotification.setValue(notification.isFollowed, forKey: "isFollowed")
                } else {
                    // Create a new notification entity
                    let _ = notification.getFollowEntity(context: managedObjectContext)
                }
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .replyPost:
            let _ = notification.getPostCommentEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .replyCase:
            let _ = notification.getCaseCommentEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .replyPostComment:
            let _ = notification.getCommentReplyEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .replyCaseComment:
            let _ = notification.getCommentReplyEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .likePostReply:
            let _ = notification.getCommentLikeEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .likeCaseReply:
            let _ = notification.getCommentLikeEntity(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        case .connectionAccept:
            let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
            request.predicate = NSPredicate(format: "uid == %@ AND kind == %@", notification.uid as CVarArg, NSNumber(value: notification.kind.rawValue))
            
            do {
                let existingNotifications = try managedObjectContext.fetch(request)

                if let existingNotification = existingNotifications.first {
                    // Update the existing notification
                    existingNotification.setValue(notification.timestamp, forKey: "timestamp")
                } else {
                    // Create a new notification entity
                    let _ = notification.getFollowEntity(context: managedObjectContext)
                }
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
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
    
    /// Retrieves a Conversation object from Core Data based on the provided conversationId.
    /// - Parameter conversationId: The identifier of the conversation to retrieve.
    /// - Returns: A Conversation object if found; otherwise, nil.
    func getConversation(with conversationId: String) -> Conversation? {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "id == %@", conversationId)
        
        do {
            let conversationEntities = try managedObjectContext.fetch(request)
            guard let conversationEntity = conversationEntities.first else {
                return nil
            }
            
            return Conversation(fromEntity: conversationEntity)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
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
        request.fetchLimit = 20
        request.predicate = NSPredicate(format: "conversation.userId = %@", conversation.userId as CVarArg)
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }

        return messageEntities.compactMap { Message(fromEntity: $0) }.reversed()
    }
    
    /// Retrieves conversations that match the provided text and date criteria.
    ///
    /// - Parameters:
    ///   - text: The text to search for in conversation names.
    ///   - limit: The maximum number of conversations to retrieve.
    ///   - date: The maximum date for conversations to be retrieved.
    /// - Returns: An array of Conversation objects that match the criteria.
    func getConversations(for text: String, withLimit limit: Int, from date: Date) -> [Conversation] {
        var conversationEntities = [ConversationEntity]()
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "name CONTAINS[c] %@ AND date < %@", text, date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit

        do {
            conversationEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return conversationEntities.compactMap { Conversation(fromEntity: $0) }.reversed()
    }
    
    /// Retrieves messages that match the provided text and date criteria.
    ///
    /// - Parameters:
    ///   - text: The text to search for in message content.
    ///   - limit: The maximum number of messages to retrieve.
    ///   - date: The maximum date for messages to be retrieved.
    /// - Returns: An array of Message objects that match the criteria.
    func getMessages(for text: String, withLimit limit: Int, from date: Date) -> [Message] {
        var messageEntities = [MessageEntity]()
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "text CONTAINS[c] %@ AND sentDate < %@", text, date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        request.fetchLimit = limit
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return messageEntities.compactMap { Message(fromEntity: $0) }
    }
    
    /// Retrieves additional messages for the given conversation and date.
    ///
    /// - Parameters:
    ///   - conversation: The Conversation for which to retrieve messages.
    ///   - date: The maximum date for messages to be retrieved.
    /// - Returns: An array of Message objects for the conversation.
    func getMoreMessages(for conversation: Conversation, from date: Date) -> [Message] {
        var messageEntities = [MessageEntity]()
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        request.fetchLimit = 20
        request.predicate = NSPredicate(format: "conversation.userId = %@ AND sentDate < %@", conversation.userId as CVarArg, date as NSDate)
        
        do {
            messageEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }

        return messageEntities.compactMap { Message(fromEntity: $0) }.reversed()
    }
    
    /// Retrieves Conversation objects for the given conversation IDs.
    ///
    /// - Parameter conversationIds: An array of conversation IDs.
    /// - Returns: An array of Conversation objects.
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
    
    /// Retrieves messages around a specified message in a given conversation.
    ///
    /// - Parameters:
    ///   - conversation: The conversation where the messages belong.
    ///   - message: The central message around which to fetch other messages.
    /// - Returns: An array of messages around the central message.
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
    
    /// Retrieves the count of unread conversations.
    ///
    /// - Returns: The number of conversations with unread messages.
    func getUnreadConversations() -> Int {
        let request: NSFetchRequest<ConversationEntity> = NSFetchRequest(entityName: "ConversationEntity")
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "SUBQUERY(messages, $message, $message.isRead == %@).@count > 0", NSNumber(value: false))

        do {
            let result = try managedObjectContext.count(for: request)
            return result
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    
    /// Retrieves Notifications from the Core Data store.
    ///
    /// - Returns:
    /// An array of saved Conversations.
    func getNotifications() -> [Notification] {
        var notificationEntities = [NotificationEntity]()
        
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        let timestampDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timestampDescriptor]
        request.fetchLimit = 10
        
        do {
            notificationEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return notificationEntities.compactMap { Notification(fromEntity: $0) }
    }
    
    /// Retrieves the timestamp of the latest notification from Core Data.
    /// - Returns: The timestamp of the latest notification if available; otherwise, nil.
    func getLastNotificationDate() -> Date? {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let result = try managedObjectContext.fetch(request)
            if let latestNotification = result.first {
                return latestNotification.timestamp
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    /// Retrieves notifications that occurred before a specified date, up to a specified limit.
    /// - Parameters:
    ///   - date: The reference date.
    ///   - limit: The maximum number of notifications to retrieve.
    /// - Returns: An array of notifications that occurred before the specified date.
    func getNotifications(before date: Date, limit: Int) -> [Notification] {
        var notificationEntities = [NotificationEntity]()
        
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        let timestampDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timestampDescriptor]
        request.predicate = NSPredicate(format: "timestamp < %@", date as CVarArg)
        request.fetchLimit = limit
        
        do {
            notificationEntities = try managedObjectContext.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return notificationEntities.compactMap { Notification(fromEntity: $0) }
    }
    
    /// Retrieves the latest timestamp for a specific content ID and notification kind.
    /// - Parameters:
    ///   - contentId: The ID of the content associated with the notification.
    ///   - kind: The kind of notification.
    /// - Returns: The latest timestamp for the specified content ID and kind, or nil if no such notification is found.
    func getLastDate(forContentId contentId: String, withKind kind: NotificationKind) -> Date? {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")

        request.predicate = NSPredicate(format: "contentId == %@ AND kind == %@", contentId as CVarArg, NSNumber(value: kind.rawValue))
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
           request.fetchLimit = 1
        
        do {
            let result = try managedObjectContext.fetch(request)
            
            if let latestNotification = result.first {
                return latestNotification.timestamp
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    /// Retrieves the latest timestamp for a specific content ID, path, and notification kind.
    /// - Parameters:
    ///   - contentId: The ID of the content associated with the notification.
    ///   - path: The path associated with the notification.
    ///   - kind: The kind of notification.
    /// - Returns: The latest timestamp for the specified content ID, path, and kind, or nil if no such notification is found.
    func getLastDate(forContentId contentId: String, forPath path: [String], withKind kind: NotificationKind) -> Date? {
        guard let lastPath = path.last else { return nil }
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        
        request.predicate = NSPredicate(format: "contentId == %@ AND kind == %@ AND commentId == %@", contentId as CVarArg, NSNumber(value: kind.rawValue), lastPath as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let result = try managedObjectContext.fetch(request)
            
            if let latestNotification = result.first {
                return latestNotification.timestamp
            }
            
            return nil

        } catch {
            return nil
        }
    }
}

// MARK: - Update Operations

extension DataService {
    
    /// Updates the phase of the message to failed within the Core Data store.
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
    
    /// Edits a message by setting a specific value for the given key.
    ///
    /// - Parameters:
    ///   - message: The Message to be edited.
    ///   - value: The new value to be set.
    ///   - key: The key for which the value should be set.
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
    
    /// Reads a notification
    ///
    /// - Parameters:
    ///   - notification: The Notification to be read.
    ///   - value: The new value to be set.
    ///   - key: The key for which the value should be set.
    func read(notification: Notification) {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        request.predicate = NSPredicate(format: "id = %@", notification.id)
        
        do {
            let notificationEntities = try managedObjectContext.fetch(request)
            
            if let notificationEntity = notificationEntities.first {
                notificationEntity.setValue(true, forKey: "isRead")
            }
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }

        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Edits a Notification by setting a specific value for the given key.
    ///
    /// - Parameters:
    ///   - message: The Notification to be edited.
    ///   - value: The new value to be set.
    ///   - key: The key for which the value should be set.
    func edit(notification: Notification, set value: Any?, forKey key: String) {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        request.predicate = NSPredicate(format: "id = %@", notification.id)
        
        do {
            let notificationEntities = try managedObjectContext.fetch(request)
            if let notificationEntity = notificationEntities.first {
                notificationEntity.setValue(value, forKey: key)
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
    
    /// Deletes a given Conversation from the Core Data store.
    ///
    /// - Parameters:
    ///   - userId: The userId of the conversation to be deleted.
    func deleteConversation(userId: String) {
        let request = NSFetchRequest<ConversationEntity>(entityName: "ConversationEntity")
        request.predicate = NSPredicate(format: "userId = %@", userId as CVarArg)
        
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
    
    
    /// Deletes a message from the Core Data store.
    ///
    /// - Parameter message: The Message to be deleted.
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
    
    /// Deletes a notification from the managed object context.
    /// - Parameter notification: The notification to be deleted.
    func delete(notification: Notification) {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        request.predicate = NSPredicate(format: "id = %@", notification.id)
        
        do {
            let notificationEntities = try managedObjectContext.fetch(request)
            
            if let notificationEntity = notificationEntities.first {
                managedObjectContext.delete(notificationEntity)
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Deletes notifications of a specific kind for a given UID from the managed object context.
    /// - Parameters:
    ///   - kind: The kind of notification to be deleted.
    ///   - uid: The UID associated with the notifications.
    func deleteNotification(forKind kind: NotificationKind, withUid uid: String) {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        
        request.predicate = NSPredicate(format: "uid == %@ AND kind == %@", uid, NSNumber(value: kind.rawValue))
    
        do {
            let notificationEntities = try managedObjectContext.fetch(request)
            
            if let notificationEntity = notificationEntities.first {
                managedObjectContext.delete(notificationEntity)
            }
            
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Miscellaneous

extension DataService {
    
    /// Checks if a conversation exists for the given ID in the Core Data store.
    ///
    /// - Parameters:
    ///   - id: The ID of the conversation to check.
    ///   - completion: A closure to call with the result indicating whether the conversation exists.
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
            completion(false)
        }
    }
    
    /// Checks if a message exists for the given ID in the Core Data store.
    ///
    /// - Parameter id: The ID of the message to check.
    /// - Returns: `true` if the message exists, `false` otherwise.
    func messageExists(for id: String) -> Bool {
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "messageId == %@", id)
        
        do {
            let messageEntities = try managedObjectContext.fetch(request)
            
            if let _ = messageEntities.first {
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
