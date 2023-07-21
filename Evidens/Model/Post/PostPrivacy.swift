//
//  PostPrivacy.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/7/23.
//

import UIKit

enum PostPrivacy: Int, CaseIterable {
    case regular
    
    var title: String {
        switch self {
        case .regular: return "Public"
        }
    }
    
    var content: String {
        switch self {
        case .regular: return "Anyone on MyEvidens"
        }
    }
    
    var image: UIImage {
        switch self {
        case .regular: return UIImage(systemName: AppStrings.Icons.fillEuropeGlobe, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}
