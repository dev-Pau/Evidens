//
//  Comments.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct Comment {
    
    enum CommentType {
        case regular
        case group
    }
    
    let uid: String
    let id: String
    let timestamp: Timestamp
    let commentText: String
    let anonymous: Bool
    let isAuthor: Bool
    let isTextFromAuthor: Bool
    
    var didLike = false
    var likes = 0
    var numberOfComments = 0
    var hasCommentFromAuthor = false
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.commentText = dictionary["comment"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.anonymous = dictionary["anonymous"] as? Bool ?? false
        self.isAuthor = dictionary["isAuthor"] as? Bool ?? false
        self.isTextFromAuthor = dictionary["isTextFromAuthor"] as? Bool ?? false
    }
}

extension Comment {
    
    enum CommentOptions: String, CaseIterable {
        case back = "Go Back"
        case report = "Report Comment"
        case delete = "Delete Comment"
        
        var commentOptionsImage: UIImage {
            switch self {
            case .back:
                return UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            case .report:
                return UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            case .delete:
                return UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        }
    }
}
