//
//  SignInError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/7/23.
//

import Foundation

enum SignUpError: Error {
    case network, userFound, invalidEmail, weakPassword, unknown
    
    var title: String {
        switch self {
        case .network, .userFound, .invalidEmail, .weakPassword, .unknown: return AppStrings.Error.title
        }
    }
    
    var content: String {
        switch self {
        case .invalidEmail: return AppStrings.Error.emailFormat
        case .userFound: return AppStrings.Error.userFound
        case .network: return AppStrings.Error.network
        case .weakPassword: return AppStrings.Error.weakPassword
        case .unknown: return AppStrings.Error.unknown
        }
    }
}
