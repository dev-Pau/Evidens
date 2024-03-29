//
//  TabIcon.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

enum TabIcon: CaseIterable {
    
    case icon, cases, network, notifications, search, bookmark, drafts, profile, resources
    
    var title: String {
        
        switch self {
        case .icon, .bookmark, .drafts, .profile, .resources: return ""
        case .cases: return AppStrings.Tab.cases
        case .network: return AppStrings.Tab.network
        case .notifications: return AppStrings.Tab.notifications
        case .search: return AppStrings.Tab.search
        }
    }
    
    var regularImage: UIImage {
        switch self {
        case .icon: return (UIImage(named: AppStrings.Assets.blackLogo)?.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor))!
        case .cases: return (UIImage(systemName: AppStrings.Icons.stethoscope)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .network: return (UIImage(systemName: AppStrings.Icons.person2Fill)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.fillBell)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .search: return (UIImage(systemName: AppStrings.Icons.magnifyingglass)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .bookmark, .drafts, .profile, .resources: fatalError()
        }
    }
    
    var padImage: UIImage {
        switch self {
        case .icon: return (UIImage(named: AppStrings.Assets.blackLogo)?.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor))!
        case .cases: return (UIImage(systemName: AppStrings.Icons.stethoscope, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .network: return (UIImage(systemName: AppStrings.Icons.person2, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.bell, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .search: return (UIImage(systemName: AppStrings.Icons.magnifyingglass, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .bookmark: return (UIImage(systemName: AppStrings.Icons.bookmark, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .drafts: return (UIImage(systemName: AppStrings.Icons.squareOnSquare, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .profile: return UIImage()
        case .resources: return (UIImage(systemName: AppStrings.Icons.circleEllipsis, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        }
    }
    
    var selectedImage: UIImage {
        
        switch self {
        case .icon: return (UIImage(named: AppStrings.Assets.blackLogo)?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor))!
        case .cases: return (UIImage(systemName: AppStrings.Icons.stethoscope, withConfiguration: UIImage.SymbolConfiguration(weight: weight))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .network: return (UIImage(systemName: AppStrings.Icons.person2Fill)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.fillBell)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .search: return (UIImage(systemName: AppStrings.Icons.magnifyingglass, withConfiguration: UIImage.SymbolConfiguration(weight: weight))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .bookmark: return (UIImage(systemName: AppStrings.Icons.fillBookmark)?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .drafts: return (UIImage(systemName: AppStrings.Icons.fillSquareOnSquare, withConfiguration: UIImage.SymbolConfiguration(weight: weight))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        case .profile: return UIImage()
        case .resources: return (UIImage(systemName: AppStrings.Icons.circleEllipsis, withConfiguration: UIImage.SymbolConfiguration(weight: weight))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))!
        }
    }
    
    var weight: UIImage.SymbolWeight {
        return UIDevice.isPad ? .bold : .medium
    }
    
    
}
