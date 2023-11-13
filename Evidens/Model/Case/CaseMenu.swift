//
//  CaseMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/23.
//

import UIKit

enum CaseMenu: Int, CaseIterable {
    case delete, revision, solve, report
    
    var title: String {
        switch self {
        case .delete: return AppStrings.Menu.deleteCase
        case .revision: return AppStrings.Menu.revisionCase
        case .solve: return AppStrings.Menu.solve
        case .report: return AppStrings.Menu.reportCase
        }
    }
    
    var image: UIImage {
        switch self {
            
        case .delete: return UIImage(systemName: AppStrings.Icons.trash, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .revision: return UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .solve: return UIImage(systemName: AppStrings.Icons.heart, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .report: return UIImage(systemName: AppStrings.Icons.flag, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}
