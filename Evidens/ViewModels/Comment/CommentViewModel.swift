//
//  CommentViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import UIKit

struct CommentViewModel {
    var comment: Comment
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    var visible: Visible {
        return comment.visible
    }
    
    var anonymous: Bool {
        return comment.visible == .anonymous
    }
    
    var uid: String {
        return comment.uid
    }

    var isAuthor: Bool {
        return comment.isAuthor
    }
    
    var content: String {
        return comment.comment
    }
    
    var time: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let currentTime = formatter.string(from: comment.timestamp.dateValue(), to: Date()) ?? ""
        return AppStrings.Characters.dot + currentTime
    }
    
    var hasCommentFromAuthor: Bool {
        return numberOfComments == 0 ? false : comment.hasCommentFromAuthor
    }
    
    var numberOfComments: Int {
        return comment.numberOfComments
    }
    
    var numberOfCommentsText: String {
        return numberOfComments == 0 ? String() : "\(numberOfComments)"
    }

    var likes: Int {
        return comment.likes
    }
    
    var likesText: String {
        return likes == 0 ? String() : "\(likes)"
    }
    
    var likeImage: UIImage {
        let imageName = comment.didLike ? AppStrings.Icons.fillHeart : AppStrings.Icons.heart
        if comment.didLike {
            return (UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(primaryRed))!
        } else {
            return (UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.secondaryLabel))!
        }
    }
}
