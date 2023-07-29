//
//  Legal.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/6/23.
//

import Foundation

/// An enum representing different legal documents and policies.
enum Legal: Int, CaseIterable {
    
    case terms, privacy, cookie
    
    var title: String {
        switch self {
        case .terms: return AppStrings.Legal.terms
        case .privacy: return AppStrings.Legal.privacy
        case .cookie: return AppStrings.Legal.cookie
        }
    }
}
