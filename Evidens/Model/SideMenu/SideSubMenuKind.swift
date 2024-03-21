//
//  SideSubMenuKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit

/// An enum representing different kinds of sub-menu associated with sub-side menu.
enum SideSubMenuKind: Int, CaseIterable {
    case settings, legal, app, contact
    
    var title: String {
        switch self {
        case .settings: return AppStrings.SideMenu.settings
        case .legal: return AppStrings.SideMenu.legal
        case .app: return AppStrings.SideMenu.about
        case .contact: return AppStrings.SideMenu.contact
        }
    }
    
    var image: UIImage {
        switch self {
            
        case .settings: return (UIImage(systemName: AppStrings.Icons.gear, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        case .legal: return (UIImage(systemName: AppStrings.Icons.scalemass, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        case .app: return (UIImage(named: AppStrings.Assets.blackLogo)?.withTintColor(K.Colors.primaryColor))!
        case .contact: return (UIImage(systemName: AppStrings.Icons.circleQuestion, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        }
    }
}
