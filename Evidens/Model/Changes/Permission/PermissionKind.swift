//
//  PermissionKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/11/23.
//

import Foundation

/// An enum representing all permission kind.
enum PermissionKind {
    
    case share, profile, connections, reaction, comment
    
    var title: String {
        switch self {
            
        case .share: return AppStrings.Permission.share
        case .profile: return AppStrings.Permission.profile
        case .connections: return AppStrings.Permission.connections
        case .reaction: return AppStrings.Permission.reaction
        case .comment: return AppStrings.Permission.comment
        }
    }
}
