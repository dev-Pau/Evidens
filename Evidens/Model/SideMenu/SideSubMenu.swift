//
//  SideSubMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/6/23.
//

import UIKit

enum SideSubMenu: Int, CaseIterable {
case settings, help
    
    var title: String {
        switch self {
        case .settings: return "Settings & Legal"
        case .help: return "Help & Support"
        }
    }
    
    var kind: [SideSubMenuKind] {
        switch self {
        case .settings: return [.settings, .legal]
        case .help: return [.app, .contact]
        }
    }
}

enum SideSubMenuKind: Int, CaseIterable {
    case settings, legal, app, contact
    
    var title: String {
        switch self {
        case .settings: return "Settings"
        case .legal: return "Legal"
        case .app: return "About Us"
        case .contact: return "Contact Us"
        }
    }
    
    var image: UIImage {
        switch self {
            
        case .settings: return (UIImage(systemName: AppStrings.Icons.gear, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        case .legal: return (UIImage(systemName: AppStrings.Icons.scalemass, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        case .app: return UIImage(named: AppStrings.Assets.app)!
        case .contact: return (UIImage(systemName: AppStrings.Icons.circleQuestion, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        }
    }
}
