//
//  NotificationPreferenceKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

/// An enum mapping all the notification topic options.
enum NotificationTopic: Int, CaseIterable {
    case replies, likes, connections, cases
    
    var title: String {
        switch self {
        case .replies: return AppStrings.Notifications.Settings.repliesTitle
        case .likes: return AppStrings.Notifications.Settings.likesTitle
        case .connections: return AppStrings.Notifications.Settings.connectionsTitle
        case .cases: return AppStrings.Notifications.Settings.trackCases
        }
    }
    
    var content: String {
        switch self {
        case .replies: return AppStrings.Notifications.Settings.repliesContent
        case .likes: return AppStrings.Notifications.Settings.likesContent
        case .connections: return ""
        case .cases: return AppStrings.Notifications.Settings.trackCasesContent
        }
    }
    
    var target: String {
        switch self {
        case .replies: return AppStrings.Notifications.Settings.repliesTarget
        case .likes: return AppStrings.Notifications.Settings.likesTarget
        case .connections, .cases: return ""
        }
    }
}
