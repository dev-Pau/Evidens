//
//  NotificationGroup.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

enum NotificationGroup: Int, CaseIterable {
    case activity, network
    
    var title: String {
        switch self {
        case .activity: return AppStrings.Notifications.Settings.activity
        case .network: return AppStrings.Notifications.Settings.network
        }
    }
    
    var topic: [NotificationTopic] {
        switch self {
        case .activity: return [.replies, .likes, .followers, .messages]
        case .network: return [.cases]
        }
    }
}
