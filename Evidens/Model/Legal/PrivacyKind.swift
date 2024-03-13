//
//  PrivacyKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/24.
//

import Foundation

/// An enum representing different privacy documents and policies.
enum PrivacyKind: Int, CaseIterable {
    
    case center, privacy, contact
    
    var title: String {
        switch self {
        case .center: return AppStrings.Legal.privacyCenter
        case .privacy: return AppStrings.Legal.privacy
        case .contact: return AppStrings.Legal.contact
        }
    }
}
