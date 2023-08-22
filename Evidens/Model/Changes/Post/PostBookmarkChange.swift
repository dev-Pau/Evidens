//
//  PostBookmarkChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

struct PostBookmarkChange {
    let postId: String
    let didBookmark: Bool
    
    init(postId: String, didBookmark: Bool) {
        self.postId = postId
        self.didBookmark = didBookmark
    }
}
