//
//  Sections.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

import UIKit

/// An enum representing different types sections.
enum Section: CaseIterable {
    case about, website, publication, language
    
    var title: String {
        switch self {
            
        case .about: return AppStrings.Sections.aboutSection
        case .website: return AppStrings.Sections.websiteSection
        case .publication: return AppStrings.Sections.publicationTitle
        case .language: return AppStrings.Sections.languageTitle
        }
    }
    
    var content: String {
        switch self {
        case .about: return AppStrings.Sections.aboutContent
        case .website: return AppStrings.Sections.websiteContent
        case .publication: return AppStrings.Sections.publicationContent
        case .language: return AppStrings.Sections.languageContent
        }
    }
    
    var image: String {
        switch self {
        case .about: return AppStrings.Icons.person
        case .website: return AppStrings.Icons.paperclip
        case .publication: return AppStrings.Icons.docPublication
        case .language: return AppStrings.Icons.bubbleChar
        }
    }
}
