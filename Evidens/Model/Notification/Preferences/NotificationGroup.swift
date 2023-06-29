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
        case .activity: return "Related to you and your activity"
        case .network: return "Related to your network"
        }
    }
    
    var topic: [NotificationTopic] {
        switch self {
        case .activity: return [.replies, .likes, .followers, .messages]
        case .network: return [.cases]
        }
    }
}
