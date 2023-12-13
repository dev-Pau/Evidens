//
//  CommentSource.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/7/23.
//

import UIKit

/// An enum mapping the CommentSource.
enum CommentSource: Int {
    case post, clinicalCase
    
    var title: String {
        switch self {
        case .post: return AppStrings.Content.Post.post.lowercased()
        case .clinicalCase: return AppStrings.Title.clinicalCase.lowercased()
        }
    }
}
