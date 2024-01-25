//
//  NotificationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/12/21.
//

import UIKit

/// The viewModel for a Notification.
struct NotificationViewModel {
    var notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var time: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp, to: Date()) ?? ""
    }
    
    var isRead: Bool {
        return notification.isRead
    }
    
    var name: String {
        return notification.name ?? AppStrings.Content.Reply.theAuthor + AppStrings.Characters.space
    }
    
    func image() -> URL? {
        if notification.uid.isEmpty {
            return nil
        } else {
            if let imagePath = notification.image, let url = URL(string: imagePath) {
                return url
            } else {
                return nil
            }
        }
    }
    
    var connectText: String {
        return AppStrings.Title.connect
    }
    
    var ignoreText: String {
        return AppStrings.Network.Connection.ignore
    }
    
    var connectTextColor: UIColor {
        return .systemBackground
    }
    
    var kind: NotificationKind {
        return notification.kind
    }
    
    var summary: String {
        switch kind {
        case .likePost:
            guard let likes = notification.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others + " "
            
        case .likeCase:
            guard let likes = notification.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others + " "
            
        case .likePostReply:
            guard let likes = notification.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others + " "
            
        case .likeCaseReply:
            guard let likes = notification.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others + " "
            
        case .connectionAccept, .connectionRequest, .replyCaseComment, .replyPostComment, .replyCase, .replyPost:
            return ""
            
        case .caseApprove:
            return AppStrings.Notifications.Display.caseVisible
        }
    }
    
    var message: String {
        switch kind {
            
        case .likePost:
            guard let likes = notification.likes else { return "" }
            if likes <= 1 {
                return AppStrings.Notifications.Display.likePost
            } else {
                return AppStrings.Notifications.Display.likePostPlural
            }
        case .likeCase:
            guard let likes = notification.likes else { return "" }
            if likes <= 1 {
                return AppStrings.Notifications.Display.likeCase
            } else {
                return AppStrings.Notifications.Display.likeCasePlural
            }
        case .likePostReply, .likeCaseReply:
            guard let likes = notification.likes else { return "" }
            if likes <= 1 {
                return AppStrings.Notifications.Display.likeReply
            } else {
                return AppStrings.Notifications.Display.likeReplyPlural
            }
        case .replyPost: return AppStrings.Notifications.Display.replyPost
        case .replyPostComment, .replyCaseComment: return AppStrings.Notifications.Display.replyComment
        
        case .replyCase: return AppStrings.Notifications.Display.replyCase

        case .caseApprove: return AppStrings.Notifications.Display.connectionAccept
        case .connectionAccept: return AppStrings.Notifications.Display.connectionAccept
        case .connectionRequest: return AppStrings.Notifications.Display.connectionRequest
        }
    }
    
    var content: String {
        
        switch kind {
        case .connectionRequest, .connectionAccept:
            return ""
        default:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        }
    }
}

