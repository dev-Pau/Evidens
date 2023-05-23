//
//  Profile.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/4/23.
//

import Foundation

/// The model for a Language.
struct Language {
    var name: String
    var proficiency: String
}

/// The model for a Publication.
struct Publication {
    var title: String
    var url: String
    var date: String
    var contributorUids: [String]
}

/// The model for a Patent.
struct Patent {
    var title: String
    var number: String
    var contributorUids: [String]
}

/// The model for an Education.
struct Education {
    var school: String
    var degree: String
    var fieldOfStudy: String
    var startDate: String
    var endDate: String
}

/// The model for an Experience.
struct Experience {
    var role: String
    var company: String
    var startDate: String
    var endDate: String
}

/// The model for a RecentComment.
struct RecentComment {
    var comment: String
    var commentUid: String
    var refUid: String
    var type: Int
    var timestamp: TimeInterval
}
