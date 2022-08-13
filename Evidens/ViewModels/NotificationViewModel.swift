//
//  NotificationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/12/21.
//

import UIKit

struct NotificationViewModel {
    var notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var profileImageUrl: URL? {
        return URL(string: notification.userProfileImageUrl)
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp.dateValue(), to: Date())
    }
    

    var notificationUserInfo: NSAttributedString {
        let firstName = notification.firstName
        let lastName = notification.lastName
        let messageType = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: firstName, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(lastName)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: messageType, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: notificationComment!, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        return attributedText
    }
    
    var notificationUserImage: UIImage? {
        let notificationType = notification.type.notificationImage
        return notificationType
    }
    
    var notificationTimeStamp: String {
        return timestampString ?? ""
    }
    
    var notificationComment: String? {
        if notification.comment.isEmpty {
            return ""
        } else {
            return ": \(notification.comment)"
        }

    }
    
    var shouldShowFollowButton: Bool {
        return self.notification.type == .follow
    }
    
    var followButtonText: String {
        return notification.userIsFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return notification.userIsFollowed ? lightGrayColor : primaryColor
    }
    
    var followButtonTextColor: UIColor {
        return notification.userIsFollowed ? .black : .white
    }
    
    var notificationPostText: String? {
        if notification.type == .likeCase {
            return notification.caseText
        } else if notification.type == .likePost {
            return notification.postText
        } else {
            return ""
        }
    }
}

