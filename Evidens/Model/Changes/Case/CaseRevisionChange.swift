//
//  CaseRevisionChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

/// The model for a change in a case.
struct CaseRevisionChange {
    let caseId: String
    
    init(caseId: String) {
        self.caseId = caseId
    }
}
