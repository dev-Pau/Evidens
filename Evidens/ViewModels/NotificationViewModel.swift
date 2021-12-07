//
//  NotificationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/12/21.
//

import UIKit

struct NotificationViewModel {
    private let notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var profileImageUrl: URL? {
        return URL(string: notification.userProfileImageUrl)
    }
    

    var notificationUserInfo: NSAttributedString {
        let firstName = notification.firstName
        let lastName = notification.lastName
        let messageType = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: firstName, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(lastName)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: messageType, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        return attributedText
    }
    
    var notificationUserImage: UIImage? {
        let notificationType = notification.type.notificationImage
        return notificationType
    }
    
    var notificationPostComment: String? {
        return notification.postComment
    }
    
    var shouldShowFollowButton: Bool {
        return self.notification.type == .follow
    }
}

