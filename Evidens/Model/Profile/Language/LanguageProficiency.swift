//
//  LanguageProficiency.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/8/23.
//

import Foundation

/// An enum representing all language proficiencies.
enum LanguageProficiency: Int, CaseIterable {
    case elementary, limited, general, advanced, functionally
    
    var name: String {
        switch self {
            
        case .elementary: return AppStrings.Sections.Language.elementary
        case .limited: return AppStrings.Sections.Language.limited
        case .general: return AppStrings.Sections.Language.general
        case .advanced: return AppStrings.Sections.Language.advanced
        case .functionally: return AppStrings.Sections.Language.functionally
        }
    } 
}
