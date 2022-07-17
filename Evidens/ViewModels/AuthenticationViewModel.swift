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

struct ResetPasswordViewModel: AuthenticationViewModel {
    var email: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
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
    
    var updatePlaceholder: Bool {
        return true
    }
}

struct EmailRegistrationViewModel: AuthenticationViewModel {
    var email: String?

    var formIsValid: Bool {
        return emailIsValid
    }
    
    var buttonBackgroundColor: UIColor {
        return emailIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
    
    var emailIsValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct PasswordRegistrationViewModel: AuthenticationViewModel {
    var password: String = ""
    var privacySelected: Bool = false
    
    var formIsValid: Bool {
        return passwordIsValid
    }
    
    var buttonBackgroundColor: UIColor {
        return passwordIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
    
    var passwordHasLowerCaseLetter: Bool {
        var lowerCaseLetter: Bool = false
        
        for char in password.unicodeScalars {
            if !lowerCaseLetter {
                lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
            }
        }
        return lowerCaseLetter ? true : false
    }
    
    var passwordHasUpperCaseLetter: Bool {
        var upperCaseLetter: Bool = false
        
        for char in password.unicodeScalars {
            if !upperCaseLetter {
                upperCaseLetter = CharacterSet.uppercaseLetters.contains(char)
            }
        }
        return upperCaseLetter ? true : false
    }
    
    var passwordHasDigit: Bool {
        var hasDigit: Bool = false
        
        for char in password.unicodeScalars {
            if !hasDigit {
                hasDigit = CharacterSet.decimalDigits.contains(char)
            }
        }
        return hasDigit ? true : false
    }
    
    var passwordHasSpecialChar: Bool {
        var hasSpecialChar: Bool = false
        
        for char in password.unicodeScalars {
            if !hasSpecialChar {
                hasSpecialChar = CharacterSet.punctuationCharacters.contains(char)
            }
        }
        return hasSpecialChar ? true : false
    }
    
    var passwordMinChar: Bool {
        if password.count >= 8 {
            return true
        }
        return false
    }
    
    
    var passwordIsValid: Bool {
        
        if passwordHasSpecialChar && passwordHasDigit && passwordHasLowerCaseLetter && passwordHasUpperCaseLetter && passwordMinChar && privacySelected {
            print("password is valid")
            return true
        } else {
            return false
        }
    }
    
    var privacyConditionsButtonImage: UIImage {
        if privacySelected {
            print("privacy selected")
            return (UIImage(systemName: "checkmark.square.fill")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor))!
            
        } else {
            return (UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor))!
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
    
    var formIsValid: Bool {
        return emailIsValid && passwordIsValid && firstNameIsValid && lastNameIsValid
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }

}
