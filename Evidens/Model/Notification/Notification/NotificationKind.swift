//
//  NotificationKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/23.
//

import Foundation

/// An enum mapping the notification kind.
enum NotificationKind: Int16, CaseIterable {
    
    case likePost, likeCase, connectionRequest, replyPost, replyCase, replyPostComment, replyCaseComment, likePostReply, likeCaseReply, connectionAccept
    
    
    case caseApprove = 201

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
