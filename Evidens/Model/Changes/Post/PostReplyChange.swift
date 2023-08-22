//
//  PostReplyChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

struct PostReplyChange {
    let postId: String
    let commentId: String
    let reply: Comment
    let action: CommentAction
    
    init(postId: String, commentId: String, reply: Comment, action: CommentAction) {
        self.postId = postId
        self.commentId = commentId
        self.reply = reply
        self.action = action
    }
}
