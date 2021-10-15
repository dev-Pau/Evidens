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
    var buttonBackgroundColor: UIColor { get }
}

struct LoginViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? UIColor(rgb: 0x79CBBF) : UIColor(rgb: 0x79CBBF).withAlphaComponent(0.5)
    }
}

struct RegistrationViewModel: AuthenticationViewModel {
   
    var email: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var dateOfBirth: String?
    
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
    
    var passwordIsValid: Bool {
        var lowerCaseLetter: Bool = false
        var upperCaseLetter: Bool = false
        var digit: Bool = false
        var specialCharacter: Bool = false
        
        if password?.count ?? 00 >= 8 {
            for char in password!.unicodeScalars {
                if !lowerCaseLetter {
                    lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
                }
                if !upperCaseLetter {
                    upperCaseLetter = CharacterSet.uppercaseLetters.contains(char)
                }
                if !digit {
                    digit = CharacterSet.decimalDigits.contains(char)
                }
                if !specialCharacter {
                    specialCharacter = CharacterSet.punctuationCharacters.contains(char)
                }
            }
            //optional special characters
            if specialCharacter || (digit && lowerCaseLetter && upperCaseLetter) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    var dateOfBirthIsValid: Bool {
        return dateOfBirth?.isEmpty == false
    }
    
    var formIsValid: Bool {
        return emailIsValid && passwordIsValid && firstNameIsValid && lastNameIsValid && dateOfBirthIsValid
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? UIColor(rgb: 0x79CBBF) : UIColor(rgb: 0x79CBBF).withAlphaComponent(0.5)
    }

}
