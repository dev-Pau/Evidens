//
//  UserConnectionChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/10/23.
//

import Foundation

/// The model for a change in user connection.
struct UserConnectionChange {
    
    let uid: String
    let phase: ConnectPhase
    
    init(uid: String, phase: ConnectPhase) {
        self.uid = uid
        self.phase = phase
    }
}
