//
//  CaseCategories.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/23.
//

import Foundation

/// An enum mapping all the case filter options.
enum CaseFilter: Int, CaseIterable {
    case latest, featured
    
    var title: String {
        switch self {
        case .latest: return AppStrings.Content.Case.Category.latest
        case .featured: return AppStrings.Search.Topics.featured
        }
    }
}
