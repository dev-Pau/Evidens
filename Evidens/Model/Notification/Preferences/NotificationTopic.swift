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
        case .replies: return AppStrings.Notifications.Settings.repliesTitle
        case .likes: return AppStrings.Notifications.Settings.likesTitle
        case .followers: return AppStrings.Notifications.Settings.followersTitle
        case .messages: return AppStrings.Notifications.Settings.messagesTitle
        case .cases: return AppStrings.Notifications.Settings.trackCases
        }
    }
    
    var content: String {
        switch self {
        case .replies: return AppStrings.Notifications.Settings.repliesContent
        case .likes: return AppStrings.Notifications.Settings.likesContent
        case .followers, .messages: return ""
        case .cases: return AppStrings.Notifications.Settings.trackCasesContent
        }
    }
    
    var target: String {
        switch self {
        case .replies: return AppStrings.Notifications.Settings.repliesTarget
        case .likes: return AppStrings.Notifications.Settings.likesTarget
        case .followers, .messages, .cases: return ""
        }
    }
}
