//
//  SideMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/6/23.
//

import UIKit

/// An enum representing different side menu options.
enum SideMenu: Int, CaseIterable {
    
case profile, bookmark, create, draft
    
    var title: String {
        switch self {
        case .profile: return AppStrings.SideMenu.profile
        case .bookmark: return AppStrings.SideMenu.bookmark
        case .create: return AppStrings.SideMenu.create
        case .draft: return AppStrings.SideMenu.draft
        }
    }
    
    var image: UIImage {
        switch self {
        case .profile: return (UIImage(systemName: AppStrings.Icons.person, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        case .bookmark: return UIImage(named: AppStrings.Assets.bookmark)!.withRenderingMode(.alwaysTemplate)
        case .create: return UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal)
        case .draft: return (UIImage(systemName: AppStrings.Icons.squareOnSquare, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal))!
        }
    }
    
    var color: UIColor {
        switch self {
        case .profile, .bookmark, .draft: return UIColor.label
        case .create: return .systemBackground
        }
    }
}
