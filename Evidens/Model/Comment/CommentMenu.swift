//
//  CommentMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/7/23.
//

import UIKit

/// An enum mapping all the comment menu options.
enum CommentMenu: Int, CaseIterable {
    case back, report, delete, edit
    
    var title: String {
        switch self {
        case .back: return AppStrings.Menu.goBack
        case .report: return AppStrings.Menu.reportComment
        case .delete: return AppStrings.Menu.deleteComment
        case .edit: return AppStrings.Menu.editComment
        }
    }
    
    var image: UIImage {
        switch self {
        case .back: return UIImage(systemName: AppStrings.Icons.downLeftArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .report: return UIImage(systemName: AppStrings.Icons.flag, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .delete: return UIImage(systemName: AppStrings.Icons.trash, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .edit: return UIImage(named: AppStrings.Assets.pencil)!.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
        }
    }
}
