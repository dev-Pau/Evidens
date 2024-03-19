//
//  TabIcon.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

enum TabIcon: CaseIterable {
    
    case cases, network, notifications, search
    
    var title: String {
        
        switch self {
        case .cases: return AppStrings.Tab.cases
        case .network: return AppStrings.Tab.network
        case .notifications: return AppStrings.Tab.notifications
        case .search: return AppStrings.Tab.search
        }
    }
    
    var image: UIImage {
        switch self {
        case .cases: return (UIImage(systemName: AppStrings.Icons.clipboard)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .network: return (UIImage(systemName: AppStrings.Icons.network)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.fillBell)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .search: return (UIImage(systemName: AppStrings.Icons.magnifyingglass)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        }
    }
    
    var selectedImage: UIImage {
        
        switch self {
        case .cases: return (UIImage(systemName: AppStrings.Icons.clipboard)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .network: return (UIImage(systemName: AppStrings.Icons.network)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.fillBell)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .search: return (UIImage(systemName: AppStrings.Icons.magnifyingglass)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        }
    }
}
