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
    var uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.phase = ConnectPhase(rawValue: dictionary["phase"] as? Int ?? 6) ?? .none
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: .now)
    }
    
    init(uid: String) {
        self.uid = uid
        self.phase = .none
        self.timestamp = Timestamp(date: .now)
    }
}
