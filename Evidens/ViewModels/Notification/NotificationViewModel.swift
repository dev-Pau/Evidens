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
    
    var time: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp.dateValue(), to: Date()) ?? ""
    }
    
    var followText: String {
        return notification.userIsFollowed ?  AppStrings.Alerts.Actions.following : AppStrings.Alerts.Actions.follow
    }
    
    var followColor: UIColor {
        return notification.userIsFollowed ? .systemBackground : .label
    }
    
    var followTextColor: UIColor {
        return notification.userIsFollowed ? .label : .systemBackground
    }
    
    var kind: NotificationKind {
        return notification.kind
    }
    
    var summary: String {
        switch kind {
        case .likePost:
            guard let likes = notification.post?.likes, likes > 0 else { return "" }
            return likes == 1 ? " " : likes < 3 ? " " + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .likeCase:
            guard let likes = notification.clinicalCase?.likes, likes > 0 else { return "" }
            return likes == 1 ? " " : likes < 3 ? " " + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .follow:
            return ""
        case .replyPost:
            guard let replies = notification.comment else { return "" }
            return " "
        case .replyCase:
            guard let replies = notification.comment else { return "" }
            return " "
        }
    }
    
    var content: String {
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
        }
    }
    
    var post: Post? {
        return notification.post
    }
    
    var clinicalCase: Case? {
        return notification.clinicalCase
    }
}

