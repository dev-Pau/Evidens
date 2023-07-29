//
//  CaseUpdateViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/23.
//

import Foundation

protocol RevisionViewModel {
    var isValid: Bool { get }
}

struct CaseRevisionViewModel: RevisionViewModel {
    
    var title: String?
    var content: String?
    
    var isValid: Bool {
        return title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && content?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
