//
//  PostCommentChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

struct PostCommentChange {
    let postId: String
    let comment: Comment
    let action: CommentAction
    
    init(postId: String, comment: Comment, action: CommentAction) {
        self.postId = postId
        self.comment = comment
        self.action = action
    }
}
