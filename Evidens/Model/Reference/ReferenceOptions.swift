//
//  ReferenceOptions.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import UIKit

/// An enum mapping all the possible reference options.
enum ReferenceOptions: Int, CaseIterable {
    
    case link, citation
    
    var message: String {
        switch self  {
        case .link: return AppStrings.Reference.linkTitle
        case .citation: return AppStrings.Reference.citationTitle
        }
    }
    
    var image: UIImage {
        switch self {
        case .link, .citation:
            return (UIImage(systemName: AppStrings.Icons.note, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor))!
        }
    }
    
    var optionMenuMessage: String {
        switch self {
        case .link: return AppStrings.Reference.linkContent
        case .citation: return AppStrings.Reference.citationContent
            
        }
    }
}
