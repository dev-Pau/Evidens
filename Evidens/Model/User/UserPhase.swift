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
        case .identity: return AppStrings.User.Changes.identity
        case .pending: return AppStrings.User.Changes.pending
        case .review: return AppStrings.User.Changes.review
        case .verified: return AppStrings.User.Changes.verified

        }
    }
}
