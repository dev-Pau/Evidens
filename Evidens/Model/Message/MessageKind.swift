//
//  MessageKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/5/23.
//

import Foundation

/// An enum mapping the types of messages that can be send within the app.
enum MessageKind: Int16, CaseIterable {
    
    case text, photo, emoji
}
