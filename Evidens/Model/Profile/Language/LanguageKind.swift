//
//  LanguageKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/8/23.
//

import Foundation

enum LanguageKind: Int, CaseIterable {
    
    case english, mandarin, hindi, spanish, catalan, french, basque, aranese, romanian, galician, russian, portuguese
    
    var name: String {
        switch self {
            
        case .english: return AppStrings.Sections.Language.english
        case .mandarin: return AppStrings.Sections.Language.mandarin
        case .hindi: return AppStrings.Sections.Language.hindi
        case .spanish: return AppStrings.Sections.Language.spanish
        case .catalan: return AppStrings.Sections.Language.catalan
        case .french: return AppStrings.Sections.Language.french
        case .basque: return AppStrings.Sections.Language.basque
        case .aranese: return AppStrings.Sections.Language.aranese
        case .romanian: return AppStrings.Sections.Language.romanian
        case .galician: return AppStrings.Sections.Language.galician
        case .russian: return AppStrings.Sections.Language.russian
        case .portuguese: return AppStrings.Sections.Language.portuguese
        }
    }
}
