//
//  Case.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Firebase

struct Case {
    
    var caseTitle: String
    var caseDescription: String
    var caseSpecialities: [String]
    var caseTypeDetails: [String]
    var caseUpdates: [String]
    var likes: Int
    var numberOfComments: Int
    var numberOfViews: Int
    var numberOfBookmarks: Int
    let ownerUid: String
    let timestamp: Timestamp
    let caseId: String
    let type: CaseType
    var stage: CaseStage
    let privacyOptions: Privacy
    let ownerProfession: String
    let ownerCategory: User.UserCategory
    var diagnosis: String
    let ownerSpeciality: String
    let ownerImageUrl: String
    let ownerFirstName: String
    let ownerLastName: String
    
    let caseImageUrl: [String]
    
    var didLike = false
    var didBookmark = false
    
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
    }
    
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
    
    enum FilterCategories: String, CaseIterable {
        case explore = "Explore"
        case all = "All"
        case recents = "Recents"
    }
    
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

    init(caseId: String, dictionary: [String: Any]) {
        self.caseId = caseId
        self.caseTitle = dictionary["title"] as? String ?? ""
        self.caseDescription = dictionary["description"] as? String ?? ""
        self.caseSpecialities = dictionary["specialities"] as? [String] ?? [""]
        self.caseUpdates = dictionary["updates"] as? [String] ?? []
        self.caseTypeDetails = dictionary["details"] as? [String] ?? [""]
        self.likes = dictionary["likes"] as? Int ?? 0
        self.numberOfBookmarks = dictionary["bookmarks"] as? Int ?? 0
        self.stage = CaseStage(rawValue: dictionary["stage"] as? Int ?? 0) ?? .unresolved
        self.numberOfComments = dictionary["comments"] as? Int ?? 0
        self.numberOfViews = dictionary["views"] as? Int ?? 0
        self.diagnosis = dictionary["diagnosis"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.ownerCategory = User.UserCategory(rawValue: dictionary["ownerCategory"] as? Int ?? 00) ?? .professional
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = CaseType(rawValue: dictionary["type"] as? Int ?? 0) ?? .text
        self.ownerFirstName = dictionary["ownerFirstName"] as? String ?? ""
        self.ownerProfession = dictionary["ownerProfession"] as? String ?? ""
        self.ownerSpeciality = dictionary["ownerSpeciality"] as? String ?? ""
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerLastName = dictionary["ownerLastName"] as? String ?? ""       
        self.caseImageUrl = dictionary["caseImageUrl"] as? [String] ?? [""]
        
        self.privacyOptions = Privacy(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .visible
    }
}
