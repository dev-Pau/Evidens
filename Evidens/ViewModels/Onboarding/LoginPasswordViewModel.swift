//
//  LoginPasswordViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import Foundation

struct LoginPasswordViewModel {
    
    var password: String?

    func isPasswordEmpty() -> Bool {
        guard let password = password else {
            return true
        }
        
        guard !password.isEmpty else {
            return true
        }
        
        return false
    }
    
    mutating func set(password: String?) {
        self.password = password
    }
}
