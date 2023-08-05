//
//  LanguageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/8/23.
//

import Foundation

struct LanguageViewModel {
    
    private(set) var kind: LanguageKind?
    private(set) var proficiency: LanguageProficiency?
    
    
    var hasKind: Bool {
        return kind != nil
    }
    
    var hasProficiency: Bool {
        return proficiency != nil
    }
    
    var isValid: Bool {
        return hasKind && hasProficiency
    }
    
    var language: Language? {
        guard let kind = kind, let proficiency = proficiency else {
            return nil
        }
        return Language(kind: kind, proficiency: proficiency)
    }
    
    mutating func set(language: Language?) {
        if let language {
            self.kind = language.kind
            self.proficiency = language.proficiency
        }
    }
    
    mutating func set(kind: LanguageKind) {
        self.kind = kind
    }
    
    mutating func set(proficiency: LanguageProficiency) {
        self.proficiency = proficiency
    }
}
