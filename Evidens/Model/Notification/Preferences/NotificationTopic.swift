//
//  NotificationPreferenceKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

enum NotificationTopic: Int, CaseIterable {
    case replies, likes, followers, messages, cases
    
    var title: String {
        switch self {
        case .replies: return "Replies"
        case .likes: return "Likes"
        case .followers: return "New Followers"
        case .messages: return "Direct Messages"
        case .cases: return "Track Saved Cases"
        }
    }
    
    var content: String {
        switch self {
        case .replies: return "Receive notifications when people reply to any of your content, including posts, cases and comments."
        case .likes: return "Receive notifications when people like your posts, cases and comments. "
        case .followers, .messages: return ""
        case .cases: return "Receive notifications for updates on the cases you have saved."
        }
    }
    
    var target: String {
        switch self {
        case .replies: return "Select which notifications you receive when people reply to any of your content, including posts, cases and comments."
        case .likes: return "Select which notifications you receive when people like your posts, cases and comments. "
        case .followers, .messages, .cases: return ""
        }
    }
}
