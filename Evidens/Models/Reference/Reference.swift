//
//  Reference.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/4/23.
//

import UIKit

struct Reference {
    var option: Options
    var referenceText: String
}

extension Reference {
    
    enum Options {
        case link
        case reference
        
        var message: String {
            switch self  {
            case .link:
                return "Link Reference"
            case .reference:
                return "Author Citation"
            }
        }
        
        var image: UIImage {
            switch self {
            case .link:
                return (UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor))!
            case .reference:
                return (UIImage(systemName: "quote.bubble", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor))!
            }
        }
    }
}
