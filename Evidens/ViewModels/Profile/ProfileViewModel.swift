//
//  ProfileViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/2/23.
//

import UIKit


struct ProfileViewModel {

    var firstName: String?
    var lastName: String?
    var profileImage: Bool?
    var profileBanner: Bool?
    var speciality: Speciality?
    
    var hasName: Bool {
        return firstName?.isEmpty == false
    }
    
    var hasLastName: Bool {
        return lastName?.isEmpty == false
    }
    
    var hasSpeciality: Bool {
        return speciality != nil
    }
    
    var hasProfile: Bool {
        return profileImage ?? false
    }
    
    var hasBanner: Bool {
        return profileBanner ?? false
    }
    
    var hasBothImages: Bool {
        return profileBanner ?? false && profileImage ?? false
    }
    
    var profileIsValid: Bool {
        return hasName && hasLastName && hasSpeciality
    }
}
    
