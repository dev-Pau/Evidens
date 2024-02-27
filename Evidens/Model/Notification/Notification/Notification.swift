//
//  Notifications.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import CoreData
import Firebase

/// The model for a Notification.
struct Notification {

    let id: String
    let uid: String
    let kind: NotificationKind
    let timestamp: Date

    
    private(set) var image: String?
    var name: String?
    var username: String?

    private(set) var isFollowed: Bool?
    
    private(set) var contentId: String?
    private(set) var content: String?
    private(set) var likes: Int?
    
    private(set) var isRead: Bool
    
    private(set) var path: [String]?
    
    private(set) var commentId: String?
    
    /// Initializes a new instance of a Notification using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the notification data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.kind = NotificationKind(rawValue: Int16(dictionary["kind"] as? Int ?? 0)) ?? .likePost
        
        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Timestamp(date: Date()).dateValue()
        }
        
        if let contentId = dictionary["contentId"] as? String {
            self.contentId = contentId
        }
        
        if let path = dictionary["path"] as? [String] {
            self.path = path
            self.commentId = path.last
        }
        
        self.isRead = false
    }
    
    /// Creates a ConversationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of ConversationEntity.
    @discardableResult
    func getFollowEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.isFollowed = isFollowed ?? false
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getCaseApprove(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.timestamp = timestamp
        entity.contentId = contentId
        entity.content = content
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getCaseRevision(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.contentId = contentId
        entity.content = content
        entity.path = path
        entity.isRead = isRead

        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getPostLikeEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.likes = Int16(likes ?? 0)
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getCaseLikeEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.likes = Int16(likes ?? 0)
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getPostCommentEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.path = path
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getCaseCommentEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.path = path
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getCommentReplyEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.path = path
        entity.isRead = isRead
        
        return entity
    }
    
    /// Creates a NotificationEntity from the instance to be used with Core Data.
    ///
    /// - Returns:
    /// An instance of NotificationEntity.
    @discardableResult
    func getCommentLikeEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
        entity.username = username
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.path = path
        entity.commentId = commentId
        entity.likes = Int16(likes ?? 0)
        entity.isRead = isRead
        
        print(entity.likes)
        
        return entity
    }
    
    

    init?(fromEntity entity: NotificationEntity) {
        self.id = entity.wrappedId
        self.uid = entity.wrappedUid
        self.kind = NotificationKind(rawValue: entity.kind) ?? .connectionRequest
        self.name = entity.name
        self.username = entity.username
        self.image = entity.image
        self.timestamp = entity.wrappedTimestamp
        self.isFollowed = entity.isFollowed
        self.isRead = entity.isRead

        self.content = entity.content
        self.likes = Int(entity.likes)
        self.contentId = entity.contentId
        
        self.path = entity.path
        self.commentId = entity.commentId

    }
    
    mutating func set(post: Post) {
        self.content = post.postText
    }
    
    
    mutating func set(image: String?) {
        self.image = image
    }
    
    mutating func set(username: String) {
        self.username = username
    }
    
    mutating func set(name: String) {
        self.name = name
    }
    
    mutating func set(isFollowed: Bool) {
        self.isFollowed = isFollowed
    }
    
    mutating func set(isRead: Bool) {
        self.isRead = isRead
    }
    
    mutating func set(content: String) {
        self.content = content
    }
    
    mutating func set(contentId: String) {
        self.contentId = contentId
    }

    mutating func set(likes: Int) {
        self.likes = likes
    }
}
