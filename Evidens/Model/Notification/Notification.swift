//
//  Notifications.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase

/// The model for a Notification.
struct Notification {
    
    let uid: String
    var contentId: String
    let timestamp: Timestamp
    let type: NotificationType
    let id: String
    let userProfileImageUrl: String
    let commentId: String
    let groupId: String
    var userIsFollowed = false
    
    var post: Post?
    var clinicalCase: Case?
    var comment: Comment?
    var group: Group?
    
    /// Initializes a new instance of a Notification using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the notification data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.groupId = dictionary["groupId"] as? String ?? String()
        self.contentId = dictionary["contentId"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .likePost
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.commentId = dictionary["commentId"] as? String ?? ""
    }
    #warning("update tokens!!!! ")
    /*
     No, if a user logs in with a different account on a device, the Firebase Cloud Messaging (FCM) token associated with the device will be updated to reflect the new user. As a result, notifications sent to the previous user's token will no longer reach the device.

     Each user account should have a unique FCM token associated with it. When a user logs in or out, it's important to update the token accordingly to ensure that notifications are delivered to the correct user. Firebase provides methods to manage user-specific tokens and handle user authentication changes. By updating the token upon user login or logout, you can ensure that notifications are targeted to the correct user.
     */
}

extension Notification {
    
    /// An enum mapping the notification type.
    enum NotificationType: Int {
        case likePost
        case likeCase
        case follow
        case commentPost
        case commentCase
        case commentGroupPost
        case commentGroupCase
        case likeGroupPost
        case likeGroupCase
        
        var notificationMessage: String {
            switch self {
            case .likePost: return " liked your post"
            case .likeCase: return " liked your case"
            case .follow: return " followed you"
            case .commentPost: return " commented on your post"
            case .commentCase: return " commented on your case"
            case .commentGroupPost: return " commented your group post in"
            case .commentGroupCase: return " commented your group case in"
            case .likeGroupPost: return " liked your group post in"
            case .likeGroupCase: return " liked your group case in"
            }
        }
    }
    
    /// An enum mapping the notification menu options.
    enum NotificationMenuOptions {
        case delete
        
        var notificationMenuText: String {
            switch self {
            case .delete:
                return "Delete notification"
            }
        }
        
        var notificationMenuImage: UIImage {
            switch self {
            case .delete:
                return UIImage(systemName: "trash")!
            }
        }
    }
}
