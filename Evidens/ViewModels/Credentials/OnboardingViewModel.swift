//
//  OnboardingViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/2/23.
//

import UIKit

struct OnboardingViewModel {
    var profileImage: UIImage?
    var bannerImage: UIImage?
    var aboutText: String?
    
    var hasProfile: Bool {
        return profileImage == nil ? false : true
    }
    
    var hasBanner: Bool {
        return bannerImage == nil ? false : true
    }
    
    var hasAbout: Bool {
        guard let aboutText else {
            return false
        }
        
        return !aboutText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
