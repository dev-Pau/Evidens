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
    var numberOfComments: Int
    var numberOfShares: Int
    var numberOfBookmarks: Int
    let ownerUid: String
    let timestamp: Timestamp
    let postId: String
    let type: PostType
    let edited: Bool
    let privacyOptions: PrivacyOptions
    let imageHeight: CGFloat
    let postImageUrl: [String]
    
    var didLike = false
    var didBookmark = false
    
    
    
    enum PrivacyOptions: Int, CaseIterable {
        case all
        case group
        //case connections
        //case me
        
        var privacyOptions: Int {
            switch self {
            case .all:
                return 0
            case .group:
                return 1
            //case .me:
              //  return 2
            }
        }
        
        var privacyTitle: String {
            switch self {
            case .all:
                return "Public"
            case .group:
                return "Group"
            }
        }
        
        var privacyDescription: String {
            switch self {
                
            case .all:
                return "Anyone on MyEvidens"
            case .group:
                return "Select a group you're in"
            }
        }
        
        var privacyImage: UIImage {
            switch self {
                
            case .all:
                return UIImage(systemName: "globe.europe.africa.fill")!
            case .group:
                return UIImage(named: "groups.selected")!
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
    
    enum PostMenuOptions: String, CaseIterable {
        case delete = "Delete post"
        case edit = "Edit post"
        case report = "Report post"
        
        var menuOptionsImage: UIImage {
            switch self {
            case .delete:
                return UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .edit:
                return UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .report:
                return UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            }
        }
    }
    
    
    let postDocumentUrl: String
    let documentPages: Int
    let documentTitle: String
    
    init(postId: String, dictionary: [String: Any]) {
        self.postId = postId
        self.postText = dictionary["post"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.numberOfComments = dictionary["comments"] as? Int ?? 0
        self.numberOfBookmarks = dictionary["bookmarks"] as? Int ?? 0
        self.numberOfShares = dictionary["shares"] as? Int ?? 0
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
       
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = PostType(rawValue: dictionary["type"] as? Int ?? 0) ?? .plainText
      
        self.imageHeight = dictionary["imageHeight"] as? CGFloat ?? 0.0
        self.postImageUrl = dictionary["postImageUrl"] as? [String] ?? [""]
        
        self.postDocumentUrl = dictionary["postDocumentUrl"] as? String ?? ""
        self.documentPages = dictionary["documentPages"] as? Int ?? 0
        self.documentTitle = dictionary["documentTitle"] as? String ?? ""
        
        self.privacyOptions = PrivacyOptions(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .all
        self.edited = dictionary["edited"] as? Bool ?? false
    }
}

extension Post: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(postId)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postId == rhs.postId && lhs.likes == rhs.likes && lhs.didLike == rhs.didLike && lhs.timestamp == rhs.timestamp
    }
    
}

