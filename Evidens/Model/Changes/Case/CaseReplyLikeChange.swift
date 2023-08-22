//
//  CaseReplyLikeChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation


struct CaseReplyLikeChange {
    let caseId: String
    let commentId: String
    let replyId: String
    let didLike: Bool
    
    init(caseId: String, commentId: String, replyId: String, didLike: Bool) {
        self.caseId = caseId
        self.commentId = commentId
        self.replyId = replyId
        self.didLike = didLike
    }
}
