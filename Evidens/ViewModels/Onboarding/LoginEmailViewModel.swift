//
//  LoginEmailViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/9/23.
//

import UIKit

/// The viewModel for a LoginEmail.
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
    
    func handleLogin(presentingIn viewController: UIViewController, completion: @escaping(Result<Provider, PasswordResetError>) -> Void) {
        guard let email = email else { return }
        
        viewController.showProgressIndicator(in: viewController.view)
        
        AuthService.fetchProviders(withEmail: email) { result in

            viewController.dismissProgressIndicator()
            
            switch result {
            case .success(let provider):
                completion(.success(provider))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    mutating func set(email: String?) {
        self.email = email
    }
}
