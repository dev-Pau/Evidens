//
//  UserConnection.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation
import Firebase

struct UserConnection {
 
    var phase: ConnectPhase
    var timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.phase = ConnectPhase(rawValue: dictionary["phase"] as? Int ?? 3) ?? .none
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: .now)
    }
    
    init() {
        self.phase = .none
        self.timestamp = Timestamp(date: .now)
    }
}
