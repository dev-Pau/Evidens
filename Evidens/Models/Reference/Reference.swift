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
    
    enum Options: Int {
        case link = 0
        case reference = 1
        
        var message: String {
            switch self  {
            case .link:
                return "Link Reference"
            case .reference:
                return "Complete Citation"
            }
        }
        
        var image: UIImage {
            switch self {
            case .link:
                return (UIImage(systemName: "note", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor))!
            case .reference:
                return (UIImage(systemName: "note", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor))!
            }
        }
        
        var optionMenuMessage: String {
            switch self {
            case .link:
                return "The content you are viewing is backed up by a web link that provides evidence supporting the ideas and concepts presented."
            case .reference:
                return "The content you are viewing is supported by a reference that provides evidence supporting the ideas and concepts presented."
            }
        }
    }
}
