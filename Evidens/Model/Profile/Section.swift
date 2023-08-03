//
//  Sections.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

import UIKit


enum Sections: CaseIterable {
    case about, experience, education, patent, publication, language
    
    var title: String {
        switch self {
            
        case .about: return AppStrings.Sections.aboutSection
        case .experience: return AppStrings.Sections.experienceSection
        case .education: return AppStrings.Sections.educationSection
        case .patent: return AppStrings.Sections.patentSection
        case .publication: return AppStrings.Sections.publicationSection
        case .language: return AppStrings.Sections.languageSection
        }
    }
    
    var content: String {
        switch self {
            
        case .about: return AppStrings.Sections.aboutContent
        case .experience: return ""
        case .education: return ""
        case .patent: return ""
        case .publication: return ""
        case .language: return ""
        }
    }
}

/// The model for a Section.
struct Section {
    var name: String
}

extension Section {
    
    /// Gets all the possible languages.
    ///
    /// - Returns:
    /// An array containing all the languages.
    static func getAllLanguages() -> [Section] {
        var languages: [Section] = []
        
        let english = "English"
        languages.append(Section(name: english))
        
        let mandarin = "Mandarin"
        languages.append(Section(name: mandarin))
        
        let hindi = "Hindi"
        languages.append(Section(name: hindi))
        
        let spanish = "Spanish"
        languages.append(Section(name: spanish))
        
        let catalan = "Catalan"
        languages.append(Section(name: catalan))
        
        let french = "French"
        languages.append(Section(name: french))
        
        let basque = "Basque"
        languages.append(Section(name: basque))
        
        let aranese = "Aranese"
        languages.append(Section(name: aranese))

        let romanian = "Romanian"
        languages.append(Section(name: romanian))
        
        let galician = "Galician"
        languages.append(Section(name: galician))
        
        let russian = "Russian"
        languages.append(Section(name: russian))
        
        let portuguese = "Portuguese"
        languages.append(Section(name: portuguese))
        
        return languages
    }
    
    /// Gets all the possible language levels.
    ///
    /// - Returns:
    /// An array containing all the language levels.
    static func getAllLanguageLevels() -> [Section] {
        var languages: [Section] = []
        
        let elementary = "Elementary Proficiency"
        languages.append(Section(name: elementary))
        
        let limited = "Limited Working Proficiency"
        languages.append(Section(name: limited))
        
        let general = "General Professional Proficiency"
        languages.append(Section(name: general))
        
        let advanced = "Advanced Professional Proficiency"
        languages.append(Section(name: advanced))
        
        let functionally = "Functionally Native Proficiency"
        languages.append(Section(name: functionally))
        
        return languages
    }
}

