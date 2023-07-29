//
//  ContentKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/7/23.
//

import UIKit

/// An enum representing different kinds of content.
enum ContentKind: Int, CaseIterable {
    case post, clinicalCase
    
    var title: String {
        switch self {
        case .post: return AppStrings.Content.Post.post
        case .clinicalCase: return AppStrings.Content.Case.clinicalCase
        }
    }
    
    var image: UIImage {
        switch self {
        case .post: return UIImage(systemName: AppStrings.Icons.circlePlus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .clinicalCase: return UIImage(systemName: AppStrings.Icons.book, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}
