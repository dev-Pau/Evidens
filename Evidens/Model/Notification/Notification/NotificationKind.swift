//
//  NotificationKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/23.
//

import Foundation

/// An enum mapping the notification kind.
enum NotificationKind: Int16, CaseIterable {
    
    case likePost = 1
    case replyPost = 11
    case replyPostComment = 21
    case likePostReply = 31
    
    case likeCase = 101
    case replyCase = 111
    case replyCaseComment = 121
    case likeCaseReply = 131

    case caseApprove = 201
    
    case connectionAccept = 301
    case connectionRequest = 311

    var message: String {
        switch self {
        case .likePost: return AppStrings.Notifications.Display.likePost
        case .likeCase: return AppStrings.Notifications.Display.likeCase
        case .connectionRequest: return AppStrings.Notifications.Display.connectionRequest
        case .replyPost: return AppStrings.Notifications.Display.replyPost
        case .replyCase: return AppStrings.Notifications.Display.replyCase
        case .replyPostComment: return AppStrings.Notifications.Display.replyComment
        case .replyCaseComment: return AppStrings.Notifications.Display.replyComment
        case .likePostReply: return AppStrings.Notifications.Display.likeReply
        case .likeCaseReply: return AppStrings.Notifications.Display.likeReply
        case .connectionAccept: return AppStrings.Notifications.Display.connectionAccept
        case .caseApprove: return AppStrings.Notifications.Display.connectionAccept
            
        }
    }
}
