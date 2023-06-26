//
//  NotificationFlow.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

enum NotificationFlow: Int {
    case tap, turn
    
    var title: String {
        switch self {
        case .tap: return "Tap \"Notifications\""
        case .turn: return "Turn \"Allow Notifications\" on"
        }
    }
}
