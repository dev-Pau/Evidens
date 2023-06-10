//
//  BookmarkKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/6/23.
//

import Foundation

/// An enum mapping the types of bookmark that can be used within the app.
enum BookmarkKind: Int, CaseIterable {
    
    case clinicalCase, post
    
    var title: String {
        switch self {
        case .clinicalCase: return "Cases"
        case .post: return "Posts"
        }
    }
}
