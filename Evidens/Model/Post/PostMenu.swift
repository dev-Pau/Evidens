//
//  PostMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/23.
//

import UIKit

enum PostMenu {
    case delete, edit, report, reference
    
    var title: String {
        switch self {
        case .delete: return AppStrings.Menu.deletePost
        case .edit: return AppStrings.Menu.editPost
        case .report: return AppStrings.Menu.reportPost
        case .reference: return AppStrings.Menu.reference
        }
    }
    
    var image: UIImage {
        switch self {
        case .delete: return UIImage(systemName: AppStrings.Icons.trash, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .edit: return UIImage(systemName: AppStrings.Icons.scribble, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .report: return UIImage(systemName: AppStrings.Icons.flag, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .reference: return UIImage(systemName: AppStrings.Icons.note, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        }
    }
}
