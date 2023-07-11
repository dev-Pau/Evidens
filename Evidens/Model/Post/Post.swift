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
    
    var postText: String
    var likes: Int
    var numberOfComments: Int
    var numberOfShares: Int
    var numberOfBookmarks: Int
    var edited: Bool
    var ownerUid: String
    let timestamp: Timestamp
    let postId: String
    var type: PostType
    var professions: [Discipline]
    var groupId: String?
    var privacyOptions: PrivacyOptions
    var postImageUrl: [String]
    var reference: ReferenceOptions
    var referenceText: String
    
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
        self.likes = dictionary["likes"] as? Int ?? 0
        self.numberOfComments = dictionary["comments"] as? Int ?? 0
        self.numberOfBookmarks = dictionary["bookmarks"] as? Int ?? 0
        self.numberOfShares = dictionary["shares"] as? Int ?? 0
        self.ownerUid = dictionary["ownerUid"] as? String ?? String()
        self.professions = (dictionary["professions"] as? [Int] ?? [0]).compactMap { Discipline(rawValue: $0) }
        #warning("check que funciona el professions i s'haurà de canviar el nom a discipline")
        //dictionary["professions"] as? [Discipline] ?? [Discipline(rawValue: 0)]
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = PostType(rawValue: dictionary["type"] as? Int ?? 0) ?? .plainText
        self.reference = ReferenceOptions(rawValue: dictionary["reference"] as? Int ?? 0) ?? .link
        self.referenceText = dictionary["referenceText"] as? String ?? String()
      
        self.postImageUrl = dictionary["postImageUrl"] as? [String] ?? []

        self.groupId = dictionary["groupId"] as? String ?? nil
        self.privacyOptions = PrivacyOptions(rawValue: dictionary["privacy"] as? Int ?? 0) ?? .all
        self.edited = dictionary["edited"] as? Bool ?? false
    }

    /// An enum mapping the post privacy options.
    enum PrivacyOptions: Int, CaseIterable {
        case all
        case group

        var privacyOptions: Int {
            switch self {
            case .all:
                return 0
            case .group:
                return 1
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
    
    /// An enum mapping the post type.
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
    
    /// An enum mapping the post options.
    enum PostMenuOptions: String, CaseIterable {
        case delete = "Delete Post"
        case edit = "Edit Post"
        case report = "Report Post"
        case reference = "Show Reference"
        
        var menuOptionsImage: UIImage {
            switch self {
            case .delete:
                return UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .edit:
                return UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .report:
                return UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            case .reference:
                return UIImage(systemName: "note", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
            }
        }
    }
}

extension Post {
    
    /// An enum mapping the content source.
    enum ContentSource {
        case home
        case user
        case search
    }
}

/// The model for a PostSource.
struct PostSource {
    var timestamp: Timestamp
    var groupId: String?
    
    /// Initializes a new instance of a PostSource using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the post source data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.groupId = dictionary["groupId"] as? String ?? nil
    }
}

