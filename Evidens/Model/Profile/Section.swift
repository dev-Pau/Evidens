//
//  Sections.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

import UIKit


enum Section: CaseIterable {
    case about, experience, education, patent, publication, language
    
    var title: String {
        switch self {
            
        case .about: return AppStrings.Sections.aboutSection
        case .experience: return AppStrings.Sections.experienceTitle
        case .education: return AppStrings.Sections.educationSection
        case .patent: return AppStrings.Sections.patentTitle
        case .publication: return AppStrings.Sections.publicationTitle
        case .language: return AppStrings.Sections.languageTitle
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
