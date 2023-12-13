//
//  SubSettingKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit


/// An enum representing different kinds of sub-settings associated with main settings.
enum SubSettingKind: Int, CaseIterable {
    case account, password, deactivate
    
    var title: String {
        switch self {
        case .account: return AppStrings.Settings.accountInfoTitle
        case .password: return AppStrings.Settings.accountPasswordTitle
        case .deactivate: return AppStrings.Settings.accountDeactivateTitle
        }
    }
    
    var content: String {
        switch self {
        case .account: return AppStrings.Settings.accountInfoContent
        case .password: return AppStrings.Settings.accountPasswordContent
        case .deactivate: return AppStrings.Settings.accountDeactivateContent
        }
    }
    
    var image: UIImage {
        switch self {
        case .account: return (UIImage(systemName: AppStrings.Icons.person, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .password: return (UIImage(systemName: AppStrings.Icons.key, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel))!
        case .deactivate: return UIImage(named: AppStrings.Assets.brokenHeart)!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        }
    }
}
