//
//  EmptyContent.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/23.
//

import Foundation

/// An enum representing different kinds of empty content states.
enum EmptyContent {
    case learn, dismiss, remove, comment
    
    var title: String {
        switch self {
            
        case .learn: return AppStrings.Content.Empty.learn
        case .dismiss: return AppStrings.Content.Empty.dismiss
        case .remove: return AppStrings.Content.Empty.remove
        case .comment: return AppStrings.Content.Empty.comment
        }
    }
}
