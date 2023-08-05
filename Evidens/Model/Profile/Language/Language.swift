//
//  Language.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// The model for a Language.
/// 
struct Language {
    let kind: LanguageKind
    let proficiency: LanguageProficiency
    
    init(dictionary: [String: Any]) {
        self.kind = LanguageKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .english
        self.proficiency = LanguageProficiency(rawValue: dictionary["proficiency"] as? Int ?? 0) ?? .limited
    }
    
    init(kind: LanguageKind, proficiency: LanguageProficiency) {
        self.kind = kind
        self.proficiency = proficiency
    }
}
