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
        case .mandarin: return AppStrings.Sections.Language.english
        case .hindi: return AppStrings.Sections.Language.english
        case .spanish: return AppStrings.Sections.Language.english
        case .catalan: return AppStrings.Sections.Language.english
        case .french: return AppStrings.Sections.Language.english
        case .basque: return AppStrings.Sections.Language.english
        case .aranese: return AppStrings.Sections.Language.english
        case .romanian: return AppStrings.Sections.Language.english
        case .galician: return AppStrings.Sections.Language.english
        case .russian: return AppStrings.Sections.Language.english
        case .portuguese: return AppStrings.Sections.Language.english
        }
    }
}
