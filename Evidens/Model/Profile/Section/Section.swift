//
//  Sections.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

import UIKit

/// An enum representing different types sections.
enum Section: CaseIterable {
    case about, website
    
    var title: String {
        switch self {
            
        case .about: return AppStrings.Sections.aboutSection
        case .website: return AppStrings.Sections.websiteSection
        }
    }
    
    var content: String {
        switch self {
        case .about: return AppStrings.Sections.aboutContent
        case .website: return AppStrings.Sections.websiteContent
        }
    }
    
    var image: String {
        switch self {
        case .about: return AppStrings.Icons.person
        case .website: return AppStrings.Icons.paperclip
        }
    }
}
