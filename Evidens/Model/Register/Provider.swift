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
        case .google: return "Credentials Change Unavailable"
        case .apple: return "Credentials Change Unavailable"
        case .undefined: return String()
        }
    }
    
    var content: String {
        switch self {
        case .password: return String()
        case .google: return "You are currently logged in with Google services. Changing credentials is not available for this type of account."
        case .apple: return "You are currently logged in using your Apple ID. Changing credentials is unavailable for Apple accounts."
        case .undefined: return "Oops, something went wrong. Please try again later."
        }
    }
    
    var id: String {
        switch self {
        case .password: return "password"
        case .google: return "google.com"
        case .apple: return "apple.com"
        case .undefined: return "undefined"
        }
    }
}
