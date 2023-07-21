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
    let caseId: String
    let uid: String
    var title: String
    var content: String
    var hashtags: [String]
    let imageUrl: [String]
    var disciplines: [Discipline]
    var specialities: [Speciality]
    var items: [CaseItem]
    var phase: CasePhase
    let timestamp: Timestamp
    var kind: CaseKind
    let privacy: CasePrivacy

    var revision: CaseRevisionKind
    var didLike = false
    var didBookmark = false
    
    var numberOfViews = 0
    var numberOfBookmarks = 0
    var likes = 0
    var numberOfComments = 0
    
    /// Initializes a new instance of a Case using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the clinical case data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(caseId: String, dictionary: [String: Any]) {
        self.caseId = caseId
        self.title = dictionary["title"] as? String ?? ""
        self.content = dictionary["content"] as? String ?? ""
        self.hashtags = dictionary["hashtags"] as? [String] ?? []
        self.disciplines = (dictionary["disciplines"] as? [Int] ?? [0]).map { Discipline(rawValue: $0 ) ?? .medicine }
        self.specialities = (dictionary["specialities"] as? [Int] ?? [0]).map { Speciality(rawValue: $0 ) ?? .generalMedicine }
        self.items = (dictionary["items"] as? [Int] ?? [0]).map { CaseItem(rawValue: $0 ) ?? .general }
        self.phase = CasePhase(rawValue: dictionary["phase"] as? Int ?? 0) ?? .unsolved
        self.revision = CaseRevisionKind(rawValue: dictionary["revision"] as? Int ?? 0) ?? .clear
        self.imageUrl = dictionary["imageUrl"] as? [String] ?? [""]
        self.kind = CaseKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .text
        self.uid = dictionary["uid"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.privacy = CasePrivacy(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .regular
    }
}

extension Case {
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
