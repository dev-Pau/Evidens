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
