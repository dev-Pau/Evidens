//
//  ConnectPhase.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation

enum ConnectPhase: Int {

    case connected, pending, received, rejected, withdraw, unconnect, none
    
    var title: String {
        switch self {
            
        case .connected: return AppStrings.Network.Connection.connected
        case .pending: return AppStrings.Network.Connection.pending
        case .received: return AppStrings.Network.Connection.received
        case .rejected, .withdraw, .unconnect, .none: return AppStrings.Network.Connection.none
        }
    }
}
