//
//  Comments.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct Comment {
    
    let uid: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String
    let timestamp: Timestamp
    let commentText: String
    let category: String
    let speciality: String
    let profession: String
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.commentText = dictionary["comment"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.profession = dictionary["profession"] as? String ?? ""
        self.speciality = dictionary["speciality"] as? String ?? ""
    }
}

/*
 "category": user.category.userCategoryString as Any,
 "speciality": user.speciality as Any,
 "profession": user.profession as Any,
 */
