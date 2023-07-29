//
//  Comments.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

/// The model for a Comment.
struct Comment {
    
    let uid: String
    let id: String
    let timestamp: Timestamp
    let comment: String
    var visible: Visible

    var didLike = false
    var likes = 0
    var numberOfComments = 0
    var isAuthor = false
    var hasCommentFromAuthor = false
    
    /// Initializes a new instance of a Comment using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the comment data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.comment = dictionary["comment"] as? String ?? ""
        self.visible = Visible(rawValue: dictionary["visible"] as? Int ?? 0) ?? .regular
    }
    
    mutating func edit(_ author: Bool) {
        self.isAuthor = author
    }
}
