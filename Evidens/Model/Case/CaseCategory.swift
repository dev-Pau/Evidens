//
//  CaseCategory.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/11/23.
//

import Foundation

/// An enum mapping all the case category options.
enum CaseCategory: Int, CaseIterable {
    case  you, latest
    
    var title: String {
        switch self {
        case .you: return AppStrings.Content.Case.Category.you
        case .latest: return AppStrings.Content.Case.Category.latest
        }
    }
}

