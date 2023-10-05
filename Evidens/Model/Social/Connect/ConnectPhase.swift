//
//  ConnectPhase.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/23.
//

import Foundation

enum ConnectPhase: Int {
    
    /// Connected: Connected to the user
    /// Pending: Send an invitation to the user
    /// Received: Received an invitation from the user
    /// Rejected: Rejected from the user
    /// Withdraw: User withdraw the invitation before accepted
    /// None: No relation with the user
    
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
