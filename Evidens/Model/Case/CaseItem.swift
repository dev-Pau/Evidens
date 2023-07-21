//
//  CaseDetails.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/23.
//

import Foundation

enum CaseItem: Int, CaseIterable {
    case general, teaching, common, uncommon, new, rare, diagnostic, multidisciplinary, technology, strategies
    
    var title: String {
        switch self {
        case .general: return AppStrings.Content.Case.Item.general
        case .teaching: return AppStrings.Content.Case.Item.teaching
        case .common: return AppStrings.Content.Case.Item.common
        case .uncommon: return AppStrings.Content.Case.Item.uncommon
        case .new: return AppStrings.Content.Case.Item.new
        case .rare: return AppStrings.Content.Case.Item.rare
        case .diagnostic: return AppStrings.Content.Case.Item.diagnostic
        case .multidisciplinary: return AppStrings.Content.Case.Item.multidisciplinary
        case .technology: return AppStrings.Content.Case.Item.technology
        case .strategies: return AppStrings.Content.Case.Item.strategies
        }
    }
}
