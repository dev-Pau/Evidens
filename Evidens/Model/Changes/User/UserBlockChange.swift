//
//  UserBlockChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/3/24.
//

import Foundation

/// The model for a change in user block.
struct UserBlockChange {
    
    let uid: String
    let phase: BlockPhase?
    
    init(uid: String, phase: BlockPhase?) {
        self.uid = uid
        self.phase = phase
    }
}
