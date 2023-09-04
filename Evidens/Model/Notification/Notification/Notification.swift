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

    private(set) var isFollowed: Bool?
    
    private(set) var contentId: String?
    private(set) var content: String?
    private(set) var likes: Int?
    
    private(set) var isRead: Bool
    
    private(set) var path: [String]?
    
    //let commentId: String

    //private(set) var content: String?
    //var contentId: String?

    //var userIsFollowed = false
    //var post: Post?
    //var clinicalCase: Case?
    //var comment: Comment?
    
    // post -> content, postId
    // comment -> content, contentId, commentId
    // reply -> content, commentId
    
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
        }
        
        self.isRead = false
        
        //self.co
        //self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
       
        //self.contentId = dictionary["contentId"] as? String ?? ""
        
        //self.commentId = dictionary["commentId"] as? String ?? ""
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
    func getPostLikeEntity(context: NSManagedObjectContext) -> NotificationEntity {
        let entity = NotificationEntity(context: context)
        
        entity.id = id
        entity.uid = uid
        entity.kind = kind.rawValue
        entity.name = name
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
        entity.image = image
        entity.timestamp = timestamp
        entity.content = content
        entity.contentId = contentId
        entity.path = path
        entity.isRead = isRead
        
        return entity
    }

    init?(fromEntity entity: NotificationEntity) {
        self.id = entity.wrappedId
        self.uid = entity.wrappedUid
        self.kind = NotificationKind(rawValue: entity.kind) ?? .follow
        self.name = entity.name
        self.image = entity.image
        self.timestamp = entity.wrappedTimestamp
        self.isFollowed = entity.isFollowed
        self.isRead = entity.isRead
        
        self.content = entity.content
        self.likes = Int(entity.likes)
        self.contentId = entity.contentId
        
        self.path = entity.path
        
        //switch NotificationKind(rawValue: entity.kind)
    }
    
    mutating func set(post: Post) {
        self.content = post.postText
    }
    
    
    mutating func set(image: String?) {
        self.image = image
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
    
    /*
     No, if a user logs in with a different account on a device, the Firebase Cloud Messaging (FCM) token associated with the device will be updated to reflect the new user. As a result, notifications sent to the previous user's token will no longer reach the device.

     Each user account should have a unique FCM token associated with it. When a user logs in or out, it's important to update the token accordingly to ensure that notifications are delivered to the correct user. Firebase provides methods to manage user-specific tokens and handle user authentication changes. By updating the token upon user login or logout, you can ensure that notifications are targeted to the correct user.
     
     
     
     IMPORTANT WHEN USER LOG OUT REMOVE THE TOKEN IMPORTANT
     */
}
