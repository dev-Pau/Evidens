//
//  Comments.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct Comment {
    
    let uid: String
    let id: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String
    let timestamp: Timestamp
    let commentText: String
    let category: String
    let speciality: String
    let profession: String
    let anonymous: Bool
    let isAuthor: Bool
    let isTextFromAuthor: Bool
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.commentText = dictionary["comment"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.anonymous = dictionary["anonymous"] as? Bool ?? false
        self.profession = dictionary["profession"] as? String ?? ""
        self.speciality = dictionary["speciality"] as? String ?? ""
        self.isAuthor = dictionary["isAuthor"] as? Bool ?? false
        self.isTextFromAuthor = dictionary["isTextFromAuthor"] as? Bool ?? false
    }
}

/*
 "category": user.category.userCategoryString as Any,
 "speciality": user.speciality as Any,
 "profession": user.profession as Any,
 */
