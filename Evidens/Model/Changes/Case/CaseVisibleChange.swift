//
//  CaseVisibleChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/8/23.
//

import Foundation

/// The model for a change in case visibility.
struct CaseVisibleChange {
    let caseId: String
    
    init(caseId: String) {
        self.caseId = caseId
    }
}
