//
//  NotificationFlow.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

/// An enum mapping all the notification flow options.
enum NotificationFlow: Int {
    case tap, turn
    
    var title: String {
        switch self {
        case .tap: return AppStrings.Notifications.Settings.tap
        case .turn: return AppStrings.Notifications.Settings.turn
        }
    }
}
