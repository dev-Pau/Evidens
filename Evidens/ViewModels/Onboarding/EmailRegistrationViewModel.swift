//
//  EmailRegistrationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import Foundation

struct EmailRegistrationViewModel: AuthenticationViewModel {
    var email: String?

    var formIsValid: Bool {
        return emailIsValid
    }
    
    var emailIsValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var emailIsEmpty: Bool {
        guard let email = email, !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            return true
        }
        
        return false
    }
}

