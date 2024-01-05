//
//  CaseVisibility.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/8/23.
//

import Foundation

/// An enum mapping all the case visibility options.
enum CaseVisibility: Int {
    case regular, deleted, pending, approve
    
    var content: String {
        switch self {
        case .regular, .deleted: return ""
        case .pending: return ""
        case .approve: return AppStrings.Content.Draft.reviewCase
        }
    }
}
