//
//  UserCellViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/10/21.
//

import Foundation


struct UserCellViewModel {
    
    private let user: User
    
    var firstName: String {
        return user.firstName!
    }
    
    var lastName: String {
        return user.lastName!
    }
    
    init(user: User) {
        self.user = user
    }
}
