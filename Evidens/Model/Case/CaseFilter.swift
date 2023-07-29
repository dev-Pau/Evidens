//
//  CaseCategories.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/23.
//

import Foundation

enum CaseFilter: Int, CaseIterable {
    case explore, all, recents, you, solved, unsolved
    
    var title: String {
        switch self {
            
        case .explore: return AppStrings.Content.Case.Filter.explore
        case .all: return AppStrings.Content.Case.Filter.all
        case .recents: return AppStrings.Content.Case.Filter.recents
        case .you: return AppStrings.Content.Case.Filter.you
        case .solved: return AppStrings.Content.Case.Filter.solved
        case .unsolved: return AppStrings.Content.Case.Filter.unsolved
        }
    }
}


