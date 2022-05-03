//
//  Post.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit
import Firebase

struct Post {
    var postText: String
    var likes: Int
    let ownerUid: String
    let timestamp: Timestamp
    let postId: String
    let ownerCategory: String
    let ownerImageUrl: String
    let ownerFirstName: String
    let ownerLastName: String
    var didLike = false
    
    //For future development, different types of posts + images, links, etc.
    //let imageUrl: String?
    
    init(postId: String, dictionary: [String: Any]) {
        self.postId = postId
        self.postText = dictionary["post"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.ownerCategory = dictionary["ownerCategory"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.ownerFirstName = dictionary["ownerFirstName"] as? String ?? ""
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerLastName = dictionary["ownerLastName"] as? String ?? ""
    }
}
