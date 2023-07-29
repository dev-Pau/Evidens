//
//  NotificationKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/23.
//

import Foundation

/// An enum mapping the notification kind.
enum NotificationKind: Int, CaseIterable {
    
    case likePost, likeCase, follow, replyPost, replyCase
    
    var message: String {
        switch self {
        case .likePost: return AppStrings.Notifications.Display.likePost
        case .likeCase: return AppStrings.Notifications.Display.likeCase
        case .follow: return AppStrings.Notifications.Display.follow
        case .replyPost: return AppStrings.Notifications.Display.replyPost
        case .replyCase: return AppStrings.Notifications.Display.replyCase
        }
    }
}

