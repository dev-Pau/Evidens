//
//  CaseSolveChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

/// The model for a change in case solve phase.
struct CaseSolveChange {
    
    let caseId: String
    let diagnosis: CaseRevisionKind?
    
    init(caseId: String, diagnosis: CaseRevisionKind?) {
        self.caseId = caseId
        self.diagnosis = diagnosis
    }
}
