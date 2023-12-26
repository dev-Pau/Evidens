//
//  FullNameViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/10/21.
//

import UIKit

/// The viewModel for a FullName.
struct FullNameViewModel: AuthenticationViewModel {
    
    private(set) var firstName: String?
    private(set) var lastName: String?
    
    var firstNameIsValid: Bool {
        guard let firstName else {
            return false
        }
        
        return !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var lastNameIsValid: Bool {
        guard let lastName else {
            return false
        }
        
        return !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var formIsValid: Bool {
        return firstNameIsValid && lastNameIsValid
    }
    
    mutating func set(firstName: String?) {
        self.firstName = firstName
    }
    
    mutating func set(lastName: String?) {
        self.lastName = lastName
    }
}

