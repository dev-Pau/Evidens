//
//  Profile.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/4/23.
//

import Foundation


/// The model for a RecentComment.
struct RecentComment {
    var comment: String
    var commentUid: String
    var refUid: String
    var type: Int
    var timestamp: TimeInterval
}
