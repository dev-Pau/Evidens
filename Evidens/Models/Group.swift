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
    
    enum Permissions: Int {
        case none = 0
        case invite = 1
        case review = 2
        case all = 3
    }

    enum GroupMembershipManagement: String, CaseIterable {
        case members = "Members"
        case requests = "Requests"
        case invited = "Invited"
        case blocked = "Blocked"
    }
    
    enum MemberType: Int {
        case owner
        case admin
        case member
        case pending
        case external
        case invited
        case blocked
        
        var memberTypeString: String {
            switch self {
                
            case .owner:
                return "Owner"
            case .admin:
                return "Admin"
            case .member:
                return "Member"
            case .pending:
                return "Pending"
            case .external:
                return "External"
            case .invited:
                return "Invited"
            case .blocked:
                return "Blocked"
            }
        }
        
        var type: Int {
            switch self {
            case .owner:
                return 0
            case .admin:
                return 1
            case .member:
                return 2
            case .pending:
                return 3
            case .external:
                return 4
            case .invited:
                return 5
            case .blocked:
                return 6
            }
        }
        
        var buttonText: String {
            switch self {
            case .owner:
                return "Manage"
            case .admin:
                return "Manage"
            case .member:
                return "Settings"
            case .pending:
                return "Pending"
            case .external:
                return "Join"
            case .invited:
                return "Invited"
            case .blocked:
                return "Blocked"
            }
        }
        
        var buttonBackgroundColor: UIColor {
            switch self {
            case .owner:
                return .secondarySystemGroupedBackground
            case .admin:
                return .secondarySystemGroupedBackground
            case .member:
                return .secondarySystemGroupedBackground
            case .pending:
                return .secondarySystemGroupedBackground
            case .external:
                return .label
            case .invited:
                return .secondarySystemGroupedBackground
            case .blocked:
                return .secondarySystemGroupedBackground
            }
        }
        
        var buttonForegroundColor: UIColor {
            switch self {
            case .owner:
                return .label
            case .admin:
                return .label
            case .member:
                return .label
            case .pending:
                return .label
            case .external:
                return .systemBackground
            case .invited:
                return .label
            case .blocked:
                return .label
            }
        }
    }
    
    enum GroupManagement: String, CaseIterable {
        case posts = "Pending content"
        case membership = "Manage membership"
        case edit = "Edit group"
        case leave = "Leave this group"
        case report = "Report this group"
        case withdraw = "Withdraw request"
        case accept = "Accept invitation"
        case ignore = "Ignore invitation"
        
        var groupManagementImage: UIImage {
            switch self {
            case .posts:
                return UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .membership:
                return UIImage(systemName: "folder.badge.person.crop", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .edit:
                return UIImage(systemName: "highlighter", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .leave:
                return UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .report:
                return UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .withdraw:
                return UIImage(systemName: "arrow.turn.up.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .accept:
                return UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            case .ignore:
                return UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!
            }
            
        }
        
    }
    
    var name: String
    var ownerUid: String
    var groupId: String
    var id: String
    var description: String
    var visibility: Visibility
    var permissions: Permissions
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
        self.visibility = Visibility(rawValue: dictionary["visibility"] as? Int ?? 0) ?? .visible
        self.permissions = Permissions(rawValue: dictionary["permissions"] as? Int ?? 0) ?? .invite
        self.categories = dictionary["categories"] as? [String] ?? [""]
        self.members = dictionary["members"] as? Int ?? 0
        self.bannerUrl = dictionary["bannerUrl"] as? String ?? ""
        self.profileUrl = dictionary["profileUrl"] as? String ?? ""
    }
}

struct UserGroup {
    var uid: String
    var memberType: Group.MemberType
    var timestamp: TimeInterval
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.memberType = Group.MemberType(rawValue: dictionary["memberType"] as? Int ?? 4) ?? .external
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? 0.0
    }
}

struct MemberTypeGroup {
    var groupId: String
    var memberType: Group.MemberType
    
    init(dictionary: [String: Any]) {
        self.groupId = dictionary["groupId"] as? String ?? ""
        self.memberType = Group.MemberType(rawValue: dictionary["memberType"] as? Int ?? 4) ?? .external
    }
}

struct ContentGroup {
    var id: String
    var type: GroupContentType
    var timestamp: TimeInterval
    
    enum GroupContentType: Int {
        case clinicalCase = 0
        case post = 1
    }
    
    enum ContentTopics: String, CaseIterable {
        case all = "All"
        case cases = "Cases"
        case posts = "Posts"
        
        var index: Int {
            switch self {
            case .all:
                return 0
            case .cases:
                return 1
            case .posts:
                return 1
            }
        }
    }
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.type = GroupContentType(rawValue: dictionary["type"] as? Int ?? 0) ?? .clinicalCase
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? 0.0
    }
}

