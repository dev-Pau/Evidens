//
//  Appearance.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/3/23.
//

import UIKit

/// An enum mapping the appearance themes.
enum Appearance: Int, CaseIterable {
    case dark, system, light
    
    var title: String {
        switch self {
        case .dark: return AppStrings.Appearance.dark
        case .system: return AppStrings.Appearance.system
        case .light: return AppStrings.Appearance.light
        }
    }
}
