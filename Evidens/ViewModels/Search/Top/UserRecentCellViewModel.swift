//
//  UserRecentCellViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/8/22.
//
import UIKit

struct UserRecentCellViewModel {
    
    private let user: User
    
    var firstName: String {
        return user.firstName!
    }
    
    var lastName: String {
        return user.lastName!
    }
    
    var profileImageUrl: URL? {
        if let imageUrl = user.profileImageUrl, imageUrl != "" {
            return URL(string: imageUrl)
        } else {
            return nil
        }
    }
    
    init(user: User) {
        self.user = user
    }
}
