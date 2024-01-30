//
//  LoginPasswordViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/23.
//

import UIKit
import FirebaseAuth

/// The viewModel for a LoginPassword.
struct LoginPasswordViewModel {
    
    var password: String?
    
    var buttonSize: CGFloat {
        return UIDevice.isPad ? 60.0 : 50.0
    }
    
    func isPasswordEmpty() -> Bool {
        guard let password = password else {
            return true
        }
        
        guard !password.isEmpty else {
            return true
        }
        
        return false
    }
    
    func logUserIn(withEmail email: String, presentingIn viewController: UIViewController, completion: @escaping(Result<AuthDataResult, LogInError>) -> Void) {
        guard let password = password else { return }

        viewController.showProgressIndicator(in: viewController.view)

        AuthService.logUserIn(withEmail: email, password: password) { result in

            viewController.dismissProgressIndicator()
            
            switch result {
            case .success(let authDataResult):
                completion(.success(authDataResult))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    mutating func set(password: String?) {
        self.password = password
    }
}
