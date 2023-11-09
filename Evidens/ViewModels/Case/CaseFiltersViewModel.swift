//
//  CaseFiltersViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/23.
//

import Foundation

struct CaseFiltersViewModel {
    
    private(set) var filter: CaseFilter

    init(filter: CaseFilter) {
        self.filter = filter
    }
    
    mutating func set(filter: CaseFilter) {
        self.filter = filter
    }
}
