//
//  ChangePasswordViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

/// The viewModel for a ChangePassword.
struct ChangePasswordViewModel: PasswordViewModel {

    var currentPassword: String?
    var newPassword: String?
    var confirmPassword: String?
    
    var formIsValid: Bool {
        return currentPassword?.isEmpty == false && newPassword?.isEmpty == false && confirmPassword?.isEmpty == false
    }
    
    var newPasswordMatch: Bool {
        return newPassword?.isEmpty == false && confirmPassword?.isEmpty == false && newPassword == confirmPassword
    }
    
    var newPasswordMinLength: Bool {
        return newPassword!.count >= 8
    }
}
