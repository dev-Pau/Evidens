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
        case .caseApprove:
            let _ = notification.getCaseApprove(context: managedObjectContext)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Retrieve Operations

extension DataService {
    
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
    
    func getNotificationCount(forUid uid: String) -> Int {
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        request.predicate = NSPredicate(format: "uid == %@", uid as CVarArg)
        
        do {
            let count = try managedObjectContext.count(for: request)
            return count
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
}

// MARK: - Update Operations

extension DataService {
    
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
            
            if let currentUid = UserDefaults.getUid(), currentUid != notification.uid {
                let count = getNotificationCount(forUid: notification.uid)
                
                if count == 0 {
                    FileGateway.shared.deleteImage(userId: notification.uid)
                }
            }
            
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
            
            
            if let currentUid = UserDefaults.getUid(), currentUid != uid {
                let count = getNotificationCount(forUid: uid)
                if count == 0 {
                    FileGateway.shared.deleteImage(userId: uid)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
