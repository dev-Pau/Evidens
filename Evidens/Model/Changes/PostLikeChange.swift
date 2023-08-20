//
//  PostLikeChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/8/23.
//

import Foundation

struct PostLikeChange {
    let postId: String
    let didLike: Bool
    
    init(postId: String, didLike: Bool) {
        self.postId = postId
        self.didLike = didLike
    }
}
