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
    var profileImage: UIImage?
    var bannerImage: UIImage?
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
        return profileImage != nil
    }
    
    var hasBanner: Bool {
        return bannerImage != nil
    }
    
    var hasBothImages: Bool {
        return bannerImage != nil && profileImage != nil
    }
    
    var profileIsValid: Bool {
        return hasName && hasLastName && hasSpeciality
    }
}
    
