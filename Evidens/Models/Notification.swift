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
        case likeCase
        case follow
        case commentPost
        case commentCase
        
        var notificationMessage: String {
            switch self {
            case .likePost: return " liked your post"
            case .likeCase: return " liked your case"
            case .follow: return " followed you"
            case .commentPost: return " commented on your post"
            case .commentCase: return " commented on your case"
            }
        }
        
        var notificationImage: UIImage? {
            switch self {
            case .likePost:
                return UIImage(systemName: "heart.fill")?.withTintColor(UIColor(rgb: 0x79CBBF), renderingMode: .alwaysOriginal)
            case .likeCase:
                return UIImage(systemName: "heart.fill")?.withTintColor(UIColor(rgb: 0x79CBBF), renderingMode: .alwaysOriginal)
            case .follow:
                return UIImage(systemName: "person.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            case .commentPost:
                return UIImage(systemName: "plus.bubble.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            case .commentCase:
                return UIImage(systemName: "plus.bubble.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
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
    let postComment: String
    var userIsFollowed = false
    
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
        self.postComment = dictionary["postComment"] as? String ?? ""
    }
}
