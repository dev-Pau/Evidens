//
//  PasswordRegistrationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import Foundation

/// The viewModel for a PasswordRegistration.
struct PasswordRegistrationViewModel: AuthenticationViewModel {
    
    var password: String?

    var formIsValid: Bool {
        return passwordIsValid
    }
    
    var passwordIsEmpty: Bool {
        guard let password = password, !password.isEmpty else {
            return true
        }
        
        return false
    }

    var passwordMinChar: Bool {
        guard let password = password else { return false }
        if password.count >= 8 {
            return true
        }
        return false
    }

    var passwordIsValid: Bool {
        if passwordMinChar {
            return true
        } else {
            return false
        }
    }
}
