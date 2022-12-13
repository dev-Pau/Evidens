//
//  Group.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/11/22.
//

import UIKit
import Firebase

struct Group {
    
    enum Visibility: Int {
        case visible
        case nonVisible
        
        var isVisible: Int {
            switch self {
            case .visible:
                return 0
            case .nonVisible:
                return 1
            }
        }
    }
    
    enum MemberType: Int {
        case owner
        case member
        
        var isOwner: Int {
            switch self {
            case .owner:
                return 0
            case .member:
                return 1
            }
        }
    }
    
    var name: String
    var ownerUid: String
    var groupId: String
    var id: String
    var description: String
    var memberType: MemberType
    var visibility: Visibility
    var categories: [String]
    var bannerUrl: String?
    var members: Int
    var profileUrl: String?
    var timestamp: Timestamp
    
    init(groupId: String, dictionary: [String: Any]) {
        self.groupId = groupId
        self.name = dictionary["name"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.visibility = dictionary["visibility"] as? Visibility ?? .visible
        self.categories = dictionary["categories"] as? [String] ?? [""]
        self.members = dictionary["members"] as? Int ?? 0
        self.memberType = dictionary["memberType"] as? MemberType ?? .member
        self.bannerUrl = dictionary["bannerUrl"] as? String ?? ""
        self.profileUrl = dictionary["profileUrl"] as? String ?? ""
    }
}
