//
//  Post.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit
import Firebase

/// The model for a Post.
struct Post {
    
    let postId: String
    var postText: String
    var uid: String
    let timestamp: Timestamp
    var kind: PostKind
    var disciplines: [Discipline]
    var privacy: PostPrivacy
    var visible: PostVisibility

    var imageUrl: [String]?
    var reference: ReferenceKind?
    var edited: Bool?
    var hashtags: [String]?
    
    var likes = 0
    var numberOfComments = 0
    var didLike = false
    var didBookmark = false
   
    /// Initializes a new instance of a Post using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the post data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(postId: String, dictionary: [String: Any]) {
        self.postId = postId
        self.postText = dictionary["post"] as? String ?? String()
        self.uid = dictionary["uid"] as? String ?? String()
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.kind = PostKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .text
        self.disciplines = (dictionary["disciplines"] as? [Int] ?? [0]).compactMap { Discipline(rawValue: $0) }
        self.privacy = PostPrivacy(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .regular
        self.visible = PostVisibility(rawValue: dictionary["visible"] as? Int ?? 0) ?? .regular
        
        if let imageUrl = dictionary["imageUrl"] as? [String] {
            self.imageUrl = imageUrl
        }
        
        if let reference = dictionary["reference"] as? Int {
            self.reference = ReferenceKind(rawValue: reference)
        }
        
        if let edited = dictionary["edited"] as? Bool {
            self.edited = edited
        }
        
        if let hashtags = dictionary["hashtags"] as? [String] {
            self.hashtags = hashtags
        }
    }
}
