//
//  PostReplyLikeChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

struct PostReplyLikeChange {
    let postId: String
    let commentId: String
    let replyId: String
    let didLike: Bool
    
    init(postId: String, commentId: String, replyId: String, didLike: Bool) {
        self.postId = postId
        self.commentId = commentId
        self.replyId = replyId
        self.didLike = didLike
    }
}
