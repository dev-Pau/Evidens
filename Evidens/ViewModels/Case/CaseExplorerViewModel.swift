//
//  CaseExplorerViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/23.
//

import Foundation

/// The viewModel for a CaseExplorer.
struct CaseExplorerViewModel {
    
    private(set) var specialities = [Speciality]()

    mutating func addSpecialities(forDiscipline discipline: Discipline) {
        specialities = discipline.specialities
    }
}
