//
//  AuthenticationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/10/21.
//

import UIKit

protocol FormViewModel {
    func updateForm()
}

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
}

struct ResetPasswordViewModel: AuthenticationViewModel {
    var email: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
    }
}

struct LoginViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    var placeholder: Bool = false
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
}

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
        guard let email = email else { return false }
        return !email.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

struct PasswordRegistrationViewModel: AuthenticationViewModel {
    
    var password: String?

    var formIsValid: Bool {
        return passwordIsValid
    }
    
    var passwordIsEmpty: Bool {
        guard let password = password else { return false }
        return password.isEmpty
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

struct RegistrationViewModel: AuthenticationViewModel {
    
    var email: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    
    var firstNameIsValid: Bool {
        return firstName?.isEmpty == false
    }
    
    var lastNameIsValid: Bool {
        return lastName?.isEmpty == false
    }
    
    var emailIsValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var formIsValid: Bool {
        return emailIsValid && firstNameIsValid && lastNameIsValid
    }
}
