//
//  CaseSolveChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/8/23.
//

import Foundation

struct CaseSolveChange {
    
    let caseId: String
    let diagnosis: CaseRevisionKind?
    
    init(caseId: String, diagnosis: CaseRevisionKind?) {
        self.caseId = caseId
        self.diagnosis = diagnosis
    }
}
