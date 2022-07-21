//
//  Post.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit
import Firebase

struct Post {
    
    enum PrivacyOptions: Int {
        case all
        case connections
        case me
        
        var privacyOptions: Int {
            switch self {
            case .all:
                return 0
            case .connections:
                return 1
            case .me:
                return 2
            }
        }
    }
    
    enum PostType: Int {
        case plainText
        case textWithImage
        case textWithTwoImage
        case textWithThreeImage
        case textWithFourImage
        case document
        case poll
        case video
        
        var postType: Int {
            switch self {
            case .plainText:
                return 0
            case .textWithImage:
                return 1
            case .textWithTwoImage:
                return 2
            case .textWithThreeImage:
                return 3
            case .textWithFourImage:
                return 4
            case .document:
                return 5
            case .poll:
                return 6
            case .video:
                return 7
            }
        }
    }
    
    var postText: String
    var likes: Int
    var numberOfComments: Int
    var numberOfShares: Int
    var numberOfBookmarks: Int
    let ownerUid: String
    let timestamp: Timestamp
    let postId: String
    let type: PostType
    let ownerCategory: String
    let ownerProfession: String
    let ownerSpeciality: String
    
    let ownerImageUrl: String
    let ownerFirstName: String
    let ownerLastName: String
    
    let privacyOptions: PrivacyOptions
    let imagesHeight: CGFloat
    let postImageUrl: [String]
    
    let postDocumentUrl: String
    let documentPages: Int
    let documentTitle: String
    
    var didLike = false
    var didBookmark = false
    
    init(postId: String, dictionary: [String: Any]) {
        self.postId = postId
        self.postText = dictionary["post"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.numberOfComments = dictionary["comments"] as? Int ?? 0
        self.numberOfBookmarks = dictionary["bookmarks"] as? Int ?? 0
        self.numberOfShares = dictionary["shares"] as? Int ?? 0
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.ownerCategory = dictionary["ownerCategory"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = PostType(rawValue: dictionary["type"] as? Int ?? 0) ?? .plainText
        self.ownerFirstName = dictionary["ownerFirstName"] as? String ?? ""
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerLastName = dictionary["ownerLastName"] as? String ?? ""
        self.ownerProfession = dictionary["profession"] as? String ?? ""
        self.ownerSpeciality = dictionary["speciality"] as? String ?? ""
        
        self.imagesHeight = dictionary["imagesHeight"] as? CGFloat ?? 0.0
        self.postImageUrl = dictionary["postImageUrl"] as? [String] ?? [""]
        
        self.postDocumentUrl = dictionary["postDocumentUrl"] as? String ?? ""
        self.documentPages = dictionary["documentPages"] as? Int ?? 0
        self.documentTitle = dictionary["documentTitle"] as? String ?? ""
        
        self.privacyOptions = PrivacyOptions(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .all
    }
}
