//
//  UserChanges.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/6/23.
//

import Foundation

enum UserChange {
    case email, password, deactivate
    
    var title: String {
        switch self {
        case .email: return AppStrings.User.Changes.email
        case .password: return AppStrings.User.Changes.password
        case .deactivate: return AppStrings.User.Changes.deactivate
        }
    }
    
    var content: String {
        switch self {
        case .email: return AppStrings.User.Changes.emailContent
        case .password: return AppStrings.User.Changes.passwordContent
        case .deactivate: return AppStrings.User.Changes.deactivateContent
        }
    }
    
    var hint: String {
        switch self {
        case .email, .password: return AppStrings.Miscellaneous.great
        case .deactivate: return AppStrings.Miscellaneous.gotIt
        }
    }
}
