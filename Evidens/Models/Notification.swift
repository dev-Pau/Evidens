//
//  Notifications.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase

struct Notification {
    
    enum NotificationType: Int {
        case likePost
        case likeReply
        case follow
        case comment
        
        var notificationMessage: String {
            switch self {
            case .likePost: return " liked your post"
            case .likeReply: return " liked your reply"
            case .follow: return " followed you"
            case .comment: return " commented on your post"
            }
        }
    }
    
    let uid: String
    var postUrl: String?
    var postId: String?
    let timestamp: Timestamp
    let type: NotificationType
    let id: String
    let userProfileImageUrl: String
    let firstName: String
    let lastName: String
    
    init(dictionary: [String: Any]) {
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.postUrl = dictionary["postUrl"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .likePost
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
    }
}
