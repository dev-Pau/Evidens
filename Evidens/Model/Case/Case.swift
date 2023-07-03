//
//  Case.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Firebase

/// The model for a Case.
struct Case {
    
    var title: String
    var description: String
    var specialities: [String]
    var details: [String]
    var caseUpdates: [String]

    var numberOfViews: Int
    var numberOfBookmarks: Int
    let ownerUid: String
    var groupId: String?
    let timestamp: Timestamp
    var revision: CaseRevisionKind
    let caseId: String
    var type: CaseKind
    let professions: [String]
    var stage: CaseStage
    let privacyOptions: Privacy
    var diagnosis: String
    let caseImageUrl: [String]
    
    var didLike = false
    var didBookmark = false
    var likes: Int
    var numberOfComments: Int
    
    /// Initializes a new instance of a Case using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the clinical case data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(caseId: String, dictionary: [String: Any]) {
        self.caseId = caseId
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.specialities = dictionary["specialities"] as? [String] ?? [""]
        self.caseUpdates = dictionary["updates"] as? [String] ?? []
        self.details = dictionary["details"] as? [String] ?? [""]
        self.likes = dictionary["likes"] as? Int ?? 0
        self.numberOfBookmarks = dictionary["bookmarks"] as? Int ?? 0
        self.stage = CaseStage(rawValue: dictionary["stage"] as? Int ?? 0) ?? .unresolved
        self.numberOfComments = dictionary["comments"] as? Int ?? 0
        self.revision = CaseRevisionKind(rawValue: dictionary["revision"] as? Int ?? 0) ?? .clear
        self.numberOfViews = dictionary["views"] as? Int ?? 0
        self.diagnosis = dictionary["diagnosis"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.groupId = dictionary["groupId"] as? String ?? nil
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = CaseKind(rawValue: dictionary["type"] as? Int ?? 0) ?? .text
        self.caseImageUrl = dictionary["caseImageUrl"] as? [String] ?? [""]
        self.professions = dictionary["professions"] as? [String] ?? [""]
        self.privacyOptions = Privacy(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .visible
    }
}

extension Case {
    
    /// An enum mapping the stages of a clinical case.
    enum CaseStage: Int {
        case resolved
        case unresolved
        
        var caseStage: Int {
            switch self {
            case .resolved:
                return 0
            case .unresolved:
                return 1
            }
        }
        
        var caseStageString: String {
            switch self {
            case .resolved:
                return "Solved"
            case .unresolved:
                return "Unsolved"
            }
        }
    }
    
    /// An enum mapping the types of a clinical case.
    enum CaseType: Int {
        case text
        case textWithImage
        
        var caseType: Int {
            switch self {
            case .text:
                return 0
            case .textWithImage:
                return 1
            }
        }
    }
    
    /// An enum mapping the options for a clinical case.
    enum CaseMenuOptions: String, CaseIterable {
        case delete = "Delete this Case"
        case update = "Add Case Update"
        case solved = "Change to Solved"
        //case edit = "Edit Case Diagnosis"
        case report = "Report Case"
        
        var menuOptionsImage: UIImage {
            switch self {
            case .delete:
                return UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .update:
                return UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .solved:
                return UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            //case .edit:
              //  return UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .report:
                return UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            }
        }
    }
    
    /// An enum mapping the filter categories for a clinical case.
    enum FilterCategories: String, CaseIterable {
        case explore = "   Explore   "
        case all = "   All   "
        case recents = "   Recents   "
        case you = "   For You   "
        case solved = "   Solved   "
        case unsolved = "   Unsolved    "
    }
    
    /// An enum mapping the privacy options for a clinical case.
    enum Privacy: Int, CaseIterable {
        case visible
        case nonVisible
        case group
        
        var privacyType: Int {
            switch self {
            case .visible:
                return 0
            case .nonVisible:
                return 1
            case .group:
                return 2
            }
        }
        
        var privacyTypeString: String {
            switch self {
            case .visible:
                return "Public"
            case .nonVisible:
                return "Anonymous"
            case .group:
                return "Group"
            }
        }
        
        var privacyTypeSubtitle: String {
            switch self {
            case .visible:
                return "Your profile information will be visible"
            case .nonVisible:
                return "Only your profession and speciality will be visible"
            case .group:
                return "Select a group you're in"
            }
        }
        
        var privacyTypeImage: UIImage {
            switch self {
            case .visible:
                return UIImage(systemName: "globe.europe.africa.fill")!
            case .nonVisible:
                return UIImage(systemName: "eyeglasses", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .group:
                return UIImage(named: "groups.selected")!
            }
        }
    }
}

extension Case {
    
    /// An enum mapping the source options.
    enum ContentSource {
        case user
        case search
    }
    
    /// An enum mapping the content source options.
    enum FeedContentSource {
        case home
        case explore
        case filter
    }
}

/// The model of a CaseSource.
struct CaseSource {
    var timestamp: Timestamp
    var groupId: String?
    
    /// Initializes a new instance of a CaseSource using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the case source data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.groupId = dictionary["groupId"] as? String ?? nil
    }
}
