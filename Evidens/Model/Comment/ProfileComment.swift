//
//  Profile.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/4/23.
//

import Foundation


/// The model for a ProfileComment.
struct ProfileComment {
    
    var id: String
    var kind: CommentKind
    var source: CommentSource
    var contentId: String
    var path: [String]
    var timestamp: TimeInterval

    var content = ""
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.kind = CommentKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .comment
        self.source = CommentSource(rawValue: dictionary["source"] as? Int ?? 0) ?? .post
        self.contentId = dictionary["contentId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? TimeInterval()
        self.path = dictionary["path"] as? [String] ?? []
    }
    
    mutating func setComment(_ comment: String) {
        content = comment
    }
}
