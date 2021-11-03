//
//  Notifications.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/11/21.
//

import UIKit
import Firebase

struct Notifications {
    
    enum NotificationType: Int {
        case likePost
        case likeReply
        case follow
        case comment
        
        var notificationMessage: String {
            switch self {
            case .likePost: return " liked your post"
            case .likeReply: return "liked your reply"
            case .follow: return " followed you"
            case .comment: return " commented on your post"
            }
        }
    }
    
    let uid: String
    var postUrl: String?
    var postId: String?
    let timestamp: Date
    let type: NotificationType
    let id: String
    
    init(dictionary: [String: Any]) {
        self.timestamp = dictionary["timestamp"] as? Date ?? Date()
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.postUrl = dictionary["postUrl"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .likePost
    }
}
