//
//  ConnectViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/10/23.
//

import UIKit

/// The viewModel for a Connect.
struct ConnectViewModel {
    
    private(set) var user: User
    
    init(user: User) {
        self.user = user
    }
    
    var connection: UserConnection? {
        return user.connection
    }
    
    var profileUrl: String? {
        return user.profileUrl
    }
    
    var name: String {
        return user.name()
    }
    
    var details: String {
        return user.details()
    }
    
    var username: String {
        return user.getUsername()
    }
    
    var title: String {
        guard let connection = user.connection else { return "" }
        
        return connection.phase.title
    }
    
    var color: UIColor {
        guard let connection = user.connection else { return .label }
        
        switch connection.phase {
            
        case .connected, .pending, .received: return .systemBackground
        case .rejected, .withdraw, .unconnect, .none: return .label
        }
    }
    
    var foregroundColor: UIColor {
        guard let connection = user.connection else { return .systemBackground }
        
        switch connection.phase {
            
        case .connected, .pending, .received: return .label
        case .rejected, .withdraw, .unconnect, .none: return .systemBackground
        }
    }
    
    var strokeColor: UIColor {
        guard let connection = user.connection else { return .systemBackground }
        
        switch connection.phase {
            
        case .connected, .pending, .received: return K.Colors.separatorColor
        case .rejected, .withdraw, .unconnect, .none: return .clear
        }
    }
    
    var strokeWidth: CGFloat {
        guard let connection = user.connection else { return 0 }
        
        switch connection.phase {
            
        case .connected, .pending, .received: return 1
        case .rejected, .withdraw, .unconnect, .none: return 0
            
        }
    }
    
    mutating func set(phase: ConnectPhase) {
        user.editConnectionPhase(phase: phase)
    }
}
