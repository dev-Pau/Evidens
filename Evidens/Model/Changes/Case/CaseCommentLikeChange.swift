//
//  CaseCommentLikeChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

/// The model for a change in case like comment.
struct CaseCommentLikeChange {
    let caseId: String
    let commentId: String
    let didLike: Bool
    
    init(caseId: String, commentId: String, didLike: Bool) {
        self.caseId = caseId
        self.commentId = commentId
        self.didLike = didLike
    }
}
