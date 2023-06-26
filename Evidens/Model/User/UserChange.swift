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
        case .email: return "We sent you an email"
        case .password: return "Your password is updated"
        case .deactivate: return "Your account is deactivated"
        }
    }
    
    var content: String {
        switch self {
        case .email: return "We have sent you the instructions to your new email address to successfully complete the process. Please note that after finishing the process, you may be required to log in again."
        case .password: return "From now on, you will be able to use this new password to log in to your account."
        case .deactivate: return "Sorry to see you go. #GoodBye"
        }
    }
    
    var hint: String {
        switch self {
        case .email, .password: return "Great"
        case .deactivate: return "Got it"
        }
    }
}
