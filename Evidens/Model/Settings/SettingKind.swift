//
//  Settings.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

/// An enum representing different kinds of settings.
enum SettingKind: Int, CaseIterable {
    
    case account, notifications
    
    var title: String {
        switch self {
        case .account: return AppStrings.Settings.accountTitle
        case .notifications: return AppStrings.Settings.notificationsTitle
        }
    }
    
    var content: String {
        switch self {
        case .account: return AppStrings.Settings.accountContent
        case .notifications: return AppStrings.Settings.notificationsContent
        }
    }
    
    var image: UIImage {
        switch self {
        case .account: return (UIImage(systemName: AppStrings.Icons.person, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.bell, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        }
    }
    
    var subSetting: [SubSettingKind] {
        switch self {
        case .account:
            return [.account, .password, .deactivate]
        case .notifications:
            return [.deactivate]
        }
    }
}
