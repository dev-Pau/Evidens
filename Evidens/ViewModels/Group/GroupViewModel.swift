//
//  GroupViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/11/22.
//

import UIKit


struct CreateGroupViewModel {

    var name: String?
    var description: String?
    var profileImage: Bool?
    var profileBanner: Bool?
    var categories: [String]?
    
    var hasName: Bool {
        return name?.isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.isEmpty == false
    }
    
    var groupIsValid: Bool {
        return hasName && hasDescription
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
}
    

struct GroupViewModel {
    
    var group: Group
    
    var groupName: String {
        return group.name
    }
    
    var groupDescription: String {
        return group.description
    }
    
    var groupMembers: Int {
        return group.members
    }
    
    var groupProfileUrl: String? {
        return group.profileUrl
    }
    
    var groupBannerUrl: String? {
        return group.bannerUrl
    }
    
    var groupSizeString: String {
        let memberString = groupMembers > 1 ? " members" : " member"
        return String(groupMembers) + memberString
    }
    
    var settingsButtonImageString: String {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return "" }
        return uid == group.ownerUid ? "info" : "gearshape.fill"
    }
}


