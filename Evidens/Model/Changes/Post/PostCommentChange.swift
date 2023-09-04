//
//  PostCommentChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/8/23.
//

import Foundation

struct PostCommentChange {
    let postId: String
    let path: [String]
    let comment: Comment
    let action: CommentAction
    
    init(postId: String, path: [String], comment: Comment, action: CommentAction) {
        self.postId = postId
        self.path = path
        self.comment = comment
        self.action = action
    }
}
