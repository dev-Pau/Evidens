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
        return formatter.string(from: notification.timestamp, to: Date()) ?? ""
    }
    
    var isRead: Bool {
        return notification.isRead
    }
    
    var name: String {
        return notification.name ?? AppStrings.Content.Reply.theAuthor
    }
    
    func image(completion: @escaping(UIImage) -> Void) {
        if notification.uid.isEmpty {
            completion(UIImage(named: AppStrings.Assets.privacyProfile)!)
        } else {
            guard let imagePath = notification.image else {
                completion(UIImage(named: AppStrings.Assets.profile)!)
                return
            }
            
            DispatchQueue.global().async {
                if let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let userImage = UIImage(data: data) {
                    completion(userImage)
                } else {
                    completion(UIImage(named: AppStrings.Assets.profile)!)
                    return
                }
            }
        }
    }
    
    var followText: String {
        guard let isFollowed = notification.isFollowed else {
            return ""
        }
        return isFollowed ? AppStrings.Alerts.Actions.following : AppStrings.Alerts.Actions.follow
        //return
    }
    
    var followColor: UIColor {
        guard let isFollowed = notification.isFollowed else {
            return .label
        }
        return isFollowed ? .systemBackground : .label
    }
    
    var followTextColor: UIColor {
        guard let isFollowed = notification.isFollowed else {
            return .label
        }
        return isFollowed ? .label : .systemBackground
    }
    
    var kind: NotificationKind {
        return notification.kind
    }
    
    var summary: String {
        switch kind {
        case .likePost:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? " " : likes < 3 ? " " + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .likeCase:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? " " : likes < 3 ? " " + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .follow:
            return ""
        case .replyPost:
            return " "
        case .replyCase:
            return " "
        case .replyPostComment:
            return " "
        case .replyCaseComment:
            return " "
        case .likePostReply:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? " " : likes < 3 ? " " + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
        case .likeCaseReply:
            guard let likes = notification.likes, likes > 0 else { return " " }
            return likes == 1 ? " " : likes < 3 ? " " + AppStrings.Miscellaneous.andOthers + " " : AppStrings.Miscellaneous.and + " \(likes - 1) " + AppStrings.Miscellaneous.others
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
        case .follow:
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
        }
    }
}

