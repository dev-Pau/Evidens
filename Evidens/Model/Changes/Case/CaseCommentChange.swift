//
//  CaseCommentChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

struct CaseCommentChange {
    let caseId: String
    let path: [String]
    let comment: Comment
    let action: CommentAction
    
    init(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        self.caseId = caseId
        self.path = path
        self.comment = comment
        self.action = action
    }
}
