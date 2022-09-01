//
//  Sections.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

import UIKit

struct Sections {
    var name: String
}

extension Sections {
    
    static func getAllLanguages() -> [Sections] {
        var languages: [Sections] = []
        
        let english = "English"
        languages.append(Sections(name: english))
        
        let mandarin = "Mandarin"
        languages.append(Sections(name: mandarin))
        
        let hindi = "Hindi"
        languages.append(Sections(name: hindi))
        
        let spanish = "Spanish"
        languages.append(Sections(name: spanish))
        
        let catalan = "Catalan"
        languages.append(Sections(name: catalan))
        
        let french = "French"
        languages.append(Sections(name: french))
        
        let basque = "Basque"
        languages.append(Sections(name: basque))
        
        let aranese = "Aranese"
        languages.append(Sections(name: aranese))

        let romanian = "Romanian"
        languages.append(Sections(name: romanian))
        
        let galician = "Galician"
        languages.append(Sections(name: galician))
        
        let russian = "Russian"
        languages.append(Sections(name: russian))
        
        let portuguese = "Portuguese"
        languages.append(Sections(name: portuguese))
        
        return languages
    }
    
    static func getAllLanguageLevels() -> [Sections] {
        var languages: [Sections] = []
        
        let elementary = "Elementary Proficiency"
        languages.append(Sections(name: elementary))
        
        let limited = "Limited Working Proficiency"
        languages.append(Sections(name: limited))
        
        let general = "General Professional Proficiency"
        languages.append(Sections(name: general))
        
        let advanced = "Advanced Professional Proficiency"
        languages.append(Sections(name: advanced))
        
        let functionally = "Functionally Native Proficiency"
        languages.append(Sections(name: functionally))
        
        return languages
    }
}

