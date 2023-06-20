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
        case .google: return "Password Change Unavailable"
        case .apple: return "Password Change Unavailable"
        case .undefined: return String()
        }
    }
    
    var content: String {
        switch self {
        case .password: return String()
        case .google: return "You are currently logged in with Google services. Changing the password is not available for this type of account."
        case .apple: return "You are currently logged in using your Apple ID. Password change is unavailable for Apple accounts."
        case .undefined: return "Oops, something went wrong. Please try again later."
        }
    }
}
