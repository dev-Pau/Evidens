//
//  TopPeopleCellViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

struct TopPeopleCellViewModel {
    
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    var uid: String {
        return user.uid!
    }
    
    var firstName: String {
        return user.firstName!
    }
    
    var lastName: String {
        return user.lastName!
    }
    
    var fullName: String {
        return user.firstName! + " " + user.lastName!
    }
    
    var userType: String {
        return user.category!
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: user.profileImageUrl!)
    }
}
