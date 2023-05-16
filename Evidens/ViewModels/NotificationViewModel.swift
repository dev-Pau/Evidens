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
    
    var notificationTimeStamp: String {
        return timestampString ?? ""
    }
    
    var shouldShowFollowButton: Bool {
        return self.notification.type == .follow
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

    var notificationType: Notification.NotificationType {
        return notification.type
    }
    
    var notificationTypeDescription: String {
        switch notificationType {
        case .likePost:
            guard let likes = notification.post?.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .likeCase:
            guard let likes = notification.clinicalCase?.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .follow:
            return ""
        case .commentPost:
            guard let likes = notification.post?.numberOfComments, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .commentCase:
            guard let likes = notification.clinicalCase?.numberOfComments, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .commentGroupPost:
            guard let likes = notification.post?.numberOfComments, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .commentGroupCase:
            guard let likes = notification.clinicalCase?.numberOfComments, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .likeGroupPost:
            guard let likes = notification.post?.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        case .likeGroupCase:
            guard let likes = notification.clinicalCase?.likes, likes > 0 else { return "" }
            return likes == 1 ? "" : likes < 3 ? " and others " : "and \(likes - 1) others "
        }
    }
    
    var notificationTypeSummary: String {
        switch notificationType {
        case .likePost:
            guard let post = notification.post else { return "" }
            return "\"\(post.postText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likeCase:
            guard let clinicalCase = notification.clinicalCase else { return "" }
            return "\"\(clinicalCase.caseTitle.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .follow:
            return ""
        case .commentPost:
            guard let comment = notification.comment else { return "" }
            return "\"\(comment.commentText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .commentCase:
            guard let comment = notification.comment else { return "" }
            return "\"\(comment.commentText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .commentGroupPost:
            guard let comment = notification.comment else { return "" }
            return "\"\(comment.commentText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .commentGroupCase:
            guard let comment = notification.comment else { return "" }
            return "\"\(comment.commentText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likeGroupPost:
            guard let post = notification.post else { return "" }
            return "\"\(post.postText.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        case .likeGroupCase:
            guard let clinicalCase = notification.clinicalCase else { return "" }
            return "\"\(clinicalCase.caseTitle.trimmingCharacters(in: .whitespacesAndNewlines))\". "
        }
    }
    
    var groupInformation: String {
        switch notificationType {
        case .likePost:
            return ""
        case .likeCase:
            return ""
        case .follow:
            return ""
        case .commentPost:
            return ""
        case .commentCase:
            return ""
        case .commentGroupPost:
            guard let group = notification.group else { return "" }
            return "\(group.name.trimmingCharacters(in: .whitespacesAndNewlines)). "
        case .commentGroupCase:
            guard let group = notification.group else { return "" }
            return "\(group.name.trimmingCharacters(in: .whitespacesAndNewlines)). "
        case .likeGroupPost:
            guard let group = notification.group else { return "" }
            return "\(group.name.trimmingCharacters(in: .whitespacesAndNewlines)). "
        case .likeGroupCase:
            guard let group = notification.group else { return "" }
            return "\(group.name.trimmingCharacters(in: .whitespacesAndNewlines)). "
        }
    }
}

