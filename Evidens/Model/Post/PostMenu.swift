//
//  PostMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/23.
//

import UIKit

/// An enum mapping all the post menu options.
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
        case .edit: return UIImage(named: AppStrings.Assets.pencil)!.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .report: return UIImage(systemName: AppStrings.Icons.flag, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
        case .reference: return UIImage(systemName: AppStrings.Icons.quote)!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        }
    }
}
