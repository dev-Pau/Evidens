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
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp.dateValue(), to: Date())
    }
    
    var notificationTimeStamp: String {
        return timestampString ?? ""
    }
    
    var shouldShowFollowButton: Bool {
        return self.notification.kind == .follow
    }
    
    var followButtonText: String {
        return notification.userIsFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return notification.userIsFollowed ? .systemBackground : .label
    }
    
    var followButtonTextColor: UIColor {
        return notification.userIsFollowed ? .label : .systemBackground
    }
    
    var followButtonBorderColor: UIColor {
        return notification.userIsFollowed ? .quaternarySystemFill : .label
    }
    
    var followButtonBorderWidth: CGFloat {
        return notification.userIsFollowed ? 1 : 0
    }

    var kind: NotificationKind {
        return notification.kind
    }
    
    var notificationTypeDescription: String {
        switch kind {
        case .likePost:
            guard let likes = notification.post?.likes, likes > 0 else { return "" }
            return likes == 1 ? " " : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .likeCase:
            guard let likes = notification.clinicalCase?.likes, likes > 0 else { return "" }
            return likes == 1 ? " " : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .follow:
            return " "
        case .replyPost:
            guard let likes = notification.post?.numberOfComments, likes > 0 else { return "" }
            return likes == 1 ? " " : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .replyCase:
            guard let likes = notification.clinicalCase?.numberOfComments, likes > 0 else { return "" }
            return likes == 1 ? " " : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .trackCase:
            return ""
        }
    }
    
    var notificationTypeSummary: String {
        switch kind {
        case .likePost:
            guard let post = notification.post else { return "" }
            return "\"\(post.postText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likeCase:
            guard let clinicalCase = notification.clinicalCase else { return "" }
            return "\"\(clinicalCase.title.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .follow:
            return ""
        case .replyPost:
            guard let comment = notification.comment else { return "" }
            return "\"\(comment.comment.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .replyCase:
            guard let comment = notification.comment else { return "" }
            return "\"\(comment.comment.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .trackCase:
            return "omegakekl"
        }
    }
    
    var groupInformation: String {
        switch kind {
        case .likePost:
            return ""
        case .likeCase:
            return ""
        case .follow:
            return ""
        case .replyPost:
            return ""
        case .replyCase:
            return ""
        case .trackCase:
            return ""
        }
    }
}

