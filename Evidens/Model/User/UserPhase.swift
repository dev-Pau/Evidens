//
//  UserPhase.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/7/23.
//

import Foundation

enum UserPhase: Int {
    case category, details, identity, pending, review, verified, deactivate, ban
    
    var content: String {
        switch self {
            
        case .category, .details, .deactivate, .ban: return ""
        case .identity: return "Verify Account"
        case .pending: return "Verify your account now"
        case .review: return "Reviewing"
        case .verified: return "Verified"
        }
    }
}
