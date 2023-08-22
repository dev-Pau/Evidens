//
//  CaseReplyChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

struct CaseReplyChange {
    let caseId: String
    let commentId: String
    let reply: Comment
    let action: CommentAction
    
    init(caseId: String, commentId: String, reply: Comment, action: CommentAction) {
        self.caseId = caseId
        self.commentId = commentId
        self.reply = reply
        self.action = action
    }
}
