//
//  CommentLikeChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

/// The model for a change in post like comment.
struct PostCommentLikeChange {
    let postId: String
    let commentId: String
    let didLike: Bool
    
    init(postId: String, commentId: String, didLike: Bool) {
        self.postId = postId
        self.commentId = commentId
        self.didLike = didLike
    }
}
