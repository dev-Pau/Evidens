//
//  CaseBookmarkChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

struct CaseBookmarkChange {
    let caseId: String
    let didBookmark: Bool
    
    init(caseId: String, didBookmark: Bool) {
        self.caseId = caseId
        self.didBookmark = didBookmark
    }
}
