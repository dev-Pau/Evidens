//
//  MessagePhase.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/5/23.
//

import Foundation

/// An enum mapping the phase of messages that can be send within the app.
enum MessagePhase: Int16, CaseIterable  {
    case read, sent, sending, failed, unread
}
