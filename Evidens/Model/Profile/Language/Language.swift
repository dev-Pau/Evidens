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
    var name: String
    var proficiency: String
    
    init(name: String, proficiency: String) {
        self.name = name
        self.proficiency = proficiency
    }
}
