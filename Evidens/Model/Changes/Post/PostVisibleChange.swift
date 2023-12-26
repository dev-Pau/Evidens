//
//  PostVisibleChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/8/23.
//

import Foundation

/// The model for a change in post visibility.
struct PostVisibleChange {
    let postId: String
    
    init(postId: String) {
        self.postId = postId
    }
}
