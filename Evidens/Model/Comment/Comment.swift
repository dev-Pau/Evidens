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
    let commentText: String
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
        self.commentText = dictionary["comment"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        //self.anonymous = dictionary["anonymous"] as? Bool ?? false
        self.visible = Visible(rawValue: dictionary["visible"] as? Int ?? 0) ?? .regular
        //self.isAuthor = dictionary["isAuthor"] as? Bool ?? false
        //self.isTextFromAuthor = dictionary["isTextFromAuthor"] as? Bool ?? false
    }
}

extension Comment {
    
    /// An enum mapping the comment type.
    enum CommentType {
        case regular
        case group
    }
    
    /// An enum mapping the comment options.
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
