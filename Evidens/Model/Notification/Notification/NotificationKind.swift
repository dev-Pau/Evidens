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
}
