//
//  Comments.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase
import FirebaseCore

/// The model for a Comment.
struct Comment {
    
    let uid: String
    let id: String
    let discipline: Discipline?
    let timestamp: Timestamp
    private(set) var comment: String
    var visible: Visible
    var edited: Bool?

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
        self.discipline = Discipline(rawValue: dictionary["discipline"] as? Int ?? 0) ?? .medicine
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.comment = dictionary["comment"] as? String ?? ""
        self.visible = Visible(rawValue: dictionary["visible"] as? Int ?? 0) ?? .regular
        
        if let edited = dictionary["edited"] as? Bool {
            self.edited = edited
        }
    }
    
    mutating func edit(_ author: Bool) {
        self.isAuthor = author
    }
    
    mutating func set(comment: String) {
        self.comment = comment
    }
}
