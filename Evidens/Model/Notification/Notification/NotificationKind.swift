//
//  NotificationKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/6/23.
//

import Foundation

/// An enum mapping the notification kind.
enum NotificationKind: Int, CaseIterable {
    
    case likePost, likeCase, follow, replyPost, replyCase, trackCase
    
    var message: String {
        switch self {
        case .likePost: return "liked your post"
        case .likeCase: return "liked your case"
        case .follow: return "followed you"
        case .replyPost: return "replied on your post"
        case .replyCase: return "replied on your case"
        case .trackCase: return ", whose case you saved, has added a new update to their case"
        }
    }
}

