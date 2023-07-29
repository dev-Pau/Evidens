//
//  AuthServiceError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/23.
//

import Foundation

/// An enum representing different types of errors that can occur during the password reset process.
enum PasswordResetError: Error {
    case invalidEmail, network, userNotFound, unknown
    
    var title: String {
        switch self {
        case .invalidEmail, .network, .userNotFound, .unknown: return AppStrings.Error.title
        }
    }
    
    var content: String {
        switch self {            
        case .invalidEmail: return AppStrings.Error.emailFormat
        case .network: return AppStrings.Error.network
        case .userNotFound: return AppStrings.Error.userNotFound
        case .unknown: return AppStrings.Error.unknown
        }
    }
}
