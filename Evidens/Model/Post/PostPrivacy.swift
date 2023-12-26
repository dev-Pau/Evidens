//
//  PostPrivacy.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/7/23.
//

import UIKit

/// An enum mapping all the post privacy options.
enum PostPrivacy: Int, CaseIterable {
    case regular
    
    var title: String {
        switch self {
        case .regular: return AppStrings.Content.Post.Privacy.publicTitle
        }
    }
    
    var content: String {
        switch self {
        case .regular: return AppStrings.Content.Post.Privacy.publicContent
        }
    }
    
    var image: UIImage {
        switch self {
        case .regular: return UIImage(systemName: AppStrings.Icons.fillEuropeGlobe, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}
