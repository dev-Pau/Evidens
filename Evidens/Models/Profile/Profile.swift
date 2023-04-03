//
//  Profile.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/4/23.
//

import Foundation

struct Language {
    var name: String
    var proficiency: String
    
}

struct Publication {
    var title: String
    var url: String
    var date: String
    var contributorUids: [String]
}

struct Patent {
    var title: String
    var number: String
    var contributorUids: [String]
}

struct Education {
    var school: String
    var degree: String
    var fieldOfStudy: String
    var startDate: String
    var endDate: String
}

struct Experience {
    var role: String
    var company: String
    var startDate: String
    var endDate: String
}

struct RecentComment {
    var comment: String
    var commentUid: String
    var refUid: String
    var type: Int
    var timestamp: TimeInterval
}
