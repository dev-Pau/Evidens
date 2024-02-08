//
//  Settings.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

/// An enum representing different kinds of settings.
enum SettingKind: Int, CaseIterable {
    
    case account, notifications, language, resources
    
    var title: String {
        switch self {
        case .account: return AppStrings.Settings.accountTitle
        case .notifications: return AppStrings.Settings.notificationsTitle
        case .language: return  AppStrings.Settings.languageTitle
        case .resources: return AppStrings.Settings.resourcesTitle
        }
    }
    
    var content: String {
        switch self {
        case .account: return AppStrings.Settings.accountContent
        case .notifications: return AppStrings.Settings.notificationsContent
        case .language: return AppStrings.Settings.languageContent
        case .resources: return AppStrings.Settings.resourcesContent
        }
    }
    
    var image: UIImage {
        switch self {
        case .account: return (UIImage(systemName: AppStrings.Icons.person, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray))!
        case .notifications: return (UIImage(systemName: AppStrings.Icons.bell, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray))!
        case .language: return (UIImage(systemName: AppStrings.Icons.bubbleChar, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray))!
        case .resources: return (UIImage(systemName: AppStrings.Icons.circleEllipsis, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray))!
        }
    }
    
    var subSetting: [SubSettingKind] {
        switch self {
        case .account:
            return [.account, .password, .deactivate]
        case .notifications, .resources, .language: return []
        }
    }
}
