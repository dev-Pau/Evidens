//
//  Providers.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import Foundation

enum Provider {
    case password, google, apple, undefined
    
    var title: String {
        switch self {
        case .password: return String()
        case .google: return AppStrings.User.Changes.googleTitle
        case .apple: return AppStrings.User.Changes.appleTitle
        case .undefined: return String()
        }
    }
    
    var content: String {
        switch self {
        case .password: return String()
        case .google: return AppStrings.User.Changes.googleContent
        case .apple: return AppStrings.User.Changes.appleContent
        case .undefined: return AppStrings.User.Changes.undefined
        }
    }
    
    var id: String {
        switch self {
        case .password: return AppStrings.User.Changes.passwordId
        case .google: return AppStrings.User.Changes.googleId
        case .apple: return AppStrings.User.Changes.appleId
        case .undefined: return ""
        }
    }
    
    var login: String {
        switch self {
        case .password: return String()
        case .google: return AppStrings.User.Changes.loginGoogle
        case .apple: return AppStrings.User.Changes.loginApple
        case .undefined: return AppStrings.User.Changes.undefined
        }
    }
}
