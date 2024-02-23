//
//  UsernameViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/2/24.
//

import Foundation

struct UsernameViewModel {
    
    private(set) var username = String()
    let minCount = 4
    let maxCount = 15
    
    private func hasValidNumberOfChars() -> Bool {
        
        let name = username.trimmingCharacters(in: .whitespaces)
        
        guard name.count >= minCount && name.count <= maxCount else {
            return false
        }
        
        return true
    }
    
    private func hasValidCharacters() -> Bool {
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        
        let name = username.trimmingCharacters(in: .whitespaces)
        let characterSet = CharacterSet(charactersIn: name)
        
        return validCharacters.isSuperset(of: characterSet)
    }
    
    private func hasValidKeywords() -> Bool {
        let name = username.trimmingCharacters(in: .whitespaces).lowercased()
        
        if name.contains(AppStrings.Username.admin) || name.contains(AppStrings.Username.evidens) {
            return false
        }
        
        return true
    }
    
    func formIsValid() -> Bool {
        return !username.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func addUsername(toPhase phase: UserPhase, completion: @escaping(UsernameError?) -> Void) {
        
        if !hasValidNumberOfChars() {
            completion(.length)
        } else if !hasValidCharacters() {
            completion(.characters)
        } else if !hasValidKeywords() {
            completion(.keyword)
        } else {
            
            AuthService.usernameExist(username) { exists in

                if exists {
                    completion(.unique)
                } else {
                    AuthService.addUsername(username, phase: phase) { error in
                        if let _ = error {
                            completion(.unknown)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
        
    mutating func set(username: String) {
        self.username = username
    }
}
