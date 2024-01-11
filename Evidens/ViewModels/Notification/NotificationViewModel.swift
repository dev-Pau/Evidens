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
        return notification.name ?? AppStrings.Content.Reply.theAuthor
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
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .likeCase:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .connectionRequest:
            return ""
        case .replyPost:
            return ""
        case .replyCase:
            return ""
        case .replyPostComment:
            return ""
        case .replyCaseComment:
            return ""
        case .likePostReply:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .likeCaseReply:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? "" : likes < 3 ? "" + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .connectionAccept:
            return ""
        case .caseApprove:
            return AppStrings.Notifications.Display.caseVisible
        }
    }
    
    var content: String {
        
        switch kind {
        case .likePost:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likeCase:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .connectionRequest:
            return ""
        case .replyPost:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .replyCase:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .replyPostComment:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .replyCaseComment:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likePostReply:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likeCaseReply:
            guard let content = notification.content else { return "" }
            return "\"\(content.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .caseApprove:
            guard let content = notification.content else { return "" }
            return "\(content.trimmingCharacters(in: .whitespacesAndNewlines))."
        case .connectionAccept:
            return ""
        }
    }
}

