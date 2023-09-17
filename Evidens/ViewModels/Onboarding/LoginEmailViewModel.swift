//
//  LoginEmailViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/9/23.
//

import Foundation

struct LoginEmailViewModel {
    
    var email: String?

    func isEmailEmpty() -> Bool {
        guard let email = email else {
            return true
        }
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            return true
        }
        
        return false
    }
    
    mutating func set(email: String?) {
        self.email = email
    }
}
