//
//  CommentViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import UIKit

struct CommentViewModel {
    var comment: Comment
    
    var visible: Visible {
        return comment.visible
    }
    
    var anonymous: Bool {
        return comment.visible == .anonymous
    }
    
    var commentOnwerUid: String {
        return comment.uid
    }
    
    /*
    var isTextFromAuthor: Bool {
        return comment.isTextFromAuthor
    }
    */
    
    var isAuthor: Bool {
        return comment.isAuthor
    }
    
    var commentText: String {
        return comment.commentText
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: comment.timestamp.dateValue(), to: Date())
    }
    
    var hasCommentFromAuthor: Bool {
        return numberOfComments == 0 ? false : comment.hasCommentFromAuthor
    }
    
    var numberOfComments: Int {
        return comment.numberOfComments
    }
    
    var commentsText: String {
        return numberOfComments == 0 ? String() : "\(numberOfComments)"
    }
    
    var commentsLabelText: String {
        return numberOfComments == 0 ? String() : numberOfComments == 1 ? "\(commentsReplyText)\(numberOfComments) reply" : "\(commentsReplyText)\(numberOfComments) replies"
    }
    
    var commentsReplyText: String {
        return hasCommentFromAuthor ? "• " : String()
    }
    
    var likes: Int {
        return comment.likes
    }
    
    var likesLabelText: String {
        return likes == 0 ? String() : "\(likes)"
    }
    
    var likeButtonImage: UIImage? {
        let imageName = comment.didLike ? "heart.fill" : "heart"
        if comment.didLike {
            return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.systemPink)
        } else {
            return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.secondaryLabel)
        }
    }
    
    init(comment: Comment) {
        self.comment = comment
    }
}
