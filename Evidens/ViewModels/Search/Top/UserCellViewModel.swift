//
//  TopPeopleCellViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

struct UserCellViewModel {
    
    var user: SearchUser
    
    init(user: SearchUser) {
        self.user = user
    }
    
    var uid: String {
        return user.objectID
    }
    
    var firstName: String {
        return user.firstName
    }
    
    var lastName: String {
        return user.lastName
    }
    
    var fullName: String {
        return user.firstName + " " + user.lastName
    }
        
    var userProfileImageUrl: URL? {
        return URL(string: user.profileImageUrl!)
    }
    
    var profession: String {
        if user.category == 3 {
            return user.profession + ", " + user.speciality + " · Student"
        } else {
            return user.profession + ", " + user.speciality
        }
    }
     
}
