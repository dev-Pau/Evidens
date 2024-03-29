//
//  CasePhase.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/23.
//

import Foundation

/// An enum mapping all the case phases.
enum CasePhase: Int, CaseIterable {
    case solved, unsolved
    
    var title: String {
        switch self {
        case .solved: return AppStrings.Content.Case.Phase.solved
        case .unsolved: return AppStrings.Content.Case.Phase.unsolved
        }
    }
}
