//
//  SideSubMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/6/23.
//

import UIKit

/// An enum representing different kinds of sub-menu associated with main side menu.
enum SideSubMenu: Int, CaseIterable {
case settings, help
    
    var title: String {
        switch self {
        case .settings: return AppStrings.SideMenu.settingsAndLegal
        case .help: return AppStrings.SideMenu.helpAndSupport
        }
    }
    
    var kind: [SideSubMenuKind] {
        switch self {
        case .settings: return [.settings, .legal]
        case .help: return [.app, .contact]
        }
    }
}
