//
//  CaseLikeChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

/// The model for a change in case like.
struct CaseLikeChange {
    let caseId: String
    let didLike: Bool
    
    init(caseId: String, didLike: Bool) {
        self.caseId = caseId
        self.didLike = didLike
    }
}
