//
//  CommentViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import UIKit

/// The viewModel for a Comment.
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
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
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
    
    var likeImage: UIImage? {
        let size: CGFloat = UIDevice.isPad ? 29 : 24
        
        let imageName = comment.didLike ? AppStrings.Icons.fillHeart : AppStrings.Icons.heart
        if comment.didLike {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size - 2)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor)
        } else {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size - 2)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryGray)
        }
    }
}
