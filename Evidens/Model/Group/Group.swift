//
//  Group.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/11/22.
//

import UIKit
import Firebase

/// The model for a Group.
struct Group {
    
    var name: String
    var ownerUid: String
    var groupId: String
    var id: String
    var description: String
    var visibility: GroupVisibility
    var permissions: GroupPermission
    var categories: [String]
    var professions: [String]
    let searchFor: [String]
    var bannerUrl: String?
    var members: Int
    var profileUrl: String?
    var timestamp: Timestamp
    
    /// Initializes a new instance of a Group using a dictionary.
    ///
    /// - Parameters:
    ///   - groupId: The unique id for the group.
    ///   - dictionary: A dictionary containing the group data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(groupId: String, dictionary: [String: Any]) {
        self.groupId = groupId
        self.name = dictionary["name"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.searchFor = dictionary["searchFor"] as? [String] ?? []
        self.description = dictionary["description"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.visibility = GroupVisibility(rawValue: dictionary["visibility"] as? Int ?? 0) ?? .visible
        self.permissions = GroupPermission(rawValue: dictionary["permissions"] as? Int ?? 0) ?? .invite
        self.categories = dictionary["categories"] as? [String] ?? [""]
        self.members = dictionary["members"] as? Int ?? 0
        self.professions = dictionary["professions"] as? [String] ?? []
        self.bannerUrl = dictionary["bannerUrl"] as? String ?? ""
        self.profileUrl = dictionary["profileUrl"] as? String ?? ""
    }
    
}

extension Group {
    
    
    /// An enum mapping the membership stage for a group.
    enum GroupMembershipManagement: String, CaseIterable {
        case members = "Members"
        case requests = "Requests"
        case invited = "Invited"
        case blocked = "Blocked"
    }
    
    /// An enum mapping the member types for a group.
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
                return .systemBackground
            case .admin:
                return .systemBackground
            case .member:
                return .systemBackground
            case .pending:
                return .systemBackground
            case .external:
                return .label
            case .invited:
                return .systemBackground
            case .blocked:
                return .systemBackground
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
    
    /// An enum mapping the management options for a group.
    enum GroupManagement: String, CaseIterable {
        case posts = "Pending Content"
        case membership = "Manage Membership"
        case edit = "Edit Group"
        case leave = "Leave Group"
        case report = "Report Group"
        case withdraw = "Withdraw Request"
        case accept = "Accept Invitation"
        case ignore = "Ignore Invitation"
        
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
}

/// The model for a UserGroup.
struct UserGroup {
    var uid: String
    var memberType: Group.MemberType
    var timestamp: TimeInterval
    
    /// Initializes a new instance of a UserGroup using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the user group data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.memberType = Group.MemberType(rawValue: dictionary["memberType"] as? Int ?? 4) ?? .external
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? 0.0
    }
}

/// The model for a MemberTypeGroup.
struct MemberTypeGroup {
    var groupId: String
    var memberType: Group.MemberType
    
    /// Initializes a new instance of a MemberTypeGroup using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the member tye group data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.groupId = dictionary["groupId"] as? String ?? ""
        self.memberType = Group.MemberType(rawValue: dictionary["memberType"] as? Int ?? 4) ?? .external
    }
}

/// The model for a ContentGroup.
struct ContentGroup {
    var id: String
    var type: GroupContentType
    var timestamp: TimeInterval
    
    /// Initializes a new instance of a ContentGroup using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the content group data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.type = GroupContentType(rawValue: dictionary["type"] as? Int ?? 0) ?? .clinicalCase
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? 0.0
    }
    
    /// An enum mapping the types of group content.
    enum GroupContentType: Int {
        case clinicalCase = 0
        case post = 1
    }
    
    /// An enum mapping the group content topics to search for.
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
}
