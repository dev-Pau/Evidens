//
//  Profile.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/4/23.
//

import Foundation


/// The model for a RecentComment.
struct BaseComment {
    
    var id: String
    var kind: CommentKind
    var source: CommentSource
    var referenceId: String
    var timestamp: TimeInterval
    
    var commentId: String?
    var content = ""
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.kind = CommentKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .comment
        self.source = CommentSource(rawValue: dictionary["source"] as? Int ?? 0) ?? .post
        self.referenceId = dictionary["referenceId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? TimeInterval()
        
        if let commentId = dictionary["commentId"] as? String {
            self.commentId = commentId
        }
    }
    
    mutating func setComment(_ comment: String) {
        content = comment
    }
}