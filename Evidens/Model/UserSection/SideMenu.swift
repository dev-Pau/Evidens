//
//  SideMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/6/23.
//

import UIKit

enum SideMenu: Int, CaseIterable {
    
    case profile, bookmark
    
    var title: String {
        switch self {
        case .profile: return AppStrings.SideMenu.profile
        case .bookmark: return AppStrings.SideMenu.bookmark
        }
    }
    
    var image: UIImage {
        switch self {
        case .profile: return (UIImage(systemName: AppStrings.Icons.fillPerson)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .bookmark: return UIImage(named: AppStrings.Assets.fillBookmark)!
        }
    }
}
