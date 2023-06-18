//
//  SideMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/6/23.
//

import UIKit


enum SideMenu: Int, CaseIterable {
    
case profile, bookmark, create
    
    var title: String {
        switch self {
        case .profile: return AppStrings.SideMenu.profile
        case .bookmark: return AppStrings.SideMenu.bookmark
        case .create: return AppStrings.SideMenu.create
        }
    }
    
    var image: UIImage {
        switch self {
        case .profile: return (UIImage(systemName: AppStrings.Icons.person)?.withRenderingMode(.alwaysOriginal))!
        case .bookmark: return UIImage(named: AppStrings.Assets.bookmark)!.withRenderingMode(.alwaysTemplate)
        case .create: return UIImage(named: AppStrings.Assets.fillPost)!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var color: UIColor {
        switch self {
        case .profile, .bookmark : return UIColor.label
        case .create: return primaryColor
        }
    }
}
