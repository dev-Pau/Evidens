//
//  DisciplineViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import Foundation

/// The viewModel for a Discipline.
struct DisciplineViewModel {
    
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    var disciplines: [Discipline] = Discipline.allCases
    var filteredDisciplines = [Discipline]()
    
    var discipline: Discipline?
    var isSearching: Bool = false
}
