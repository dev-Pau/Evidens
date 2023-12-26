//
//  PostEditChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

/// The model for a change in a post.
struct PostEditChange {
    let post: Post

    init(post: Post) {
        self.post = post
    }
}
