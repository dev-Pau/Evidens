//
//  PostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit

struct PostViewModel {
    var post: Post
    
    var postText: String {
        return post.postText
    }
    
    var comments: Int {
        return post.numberOfComments
    }
    
    var commentsValue: String {
        return comments == 0 ? "" : String(comments)
    }

    var edited: Bool {
        if let _ = post.edited {
            return true
        } else {
            return false
        }
    }
    
    var imageUrl: [URL?] {
        guard let imageUrl = post.imageUrl else { return [] }
        let urls = imageUrl.map { URL(string: $0) }
        return urls
    }
    
    var likes: Int {
        return post.likes
    }
    
    var likeImage: UIImage? {
        let imageName = post.didLike ? AppStrings.Icons.fillHeart : AppStrings.Icons.heart
        if post.didLike {
            return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(pinkColor)
        } else {
            return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.secondaryLabel)
        }
    }
    
    var bookMarkImage: UIImage? {
        let imageName = post.didBookmark ? AppStrings.Assets.fillBookmark : AppStrings.Assets.bookmark
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.secondaryLabel)
    }
    
    var likesText: String {
        return likes == 0 ? "" : String(post.likes)
    }
    
    var commentText: String {
        if comments > 1 { return AppStrings.Content.Comment.comments }
        else { return AppStrings.Content.Comment.comment }
    }
    
    var likeIsHidden: Bool {
        return likes > 0 ? false : true
    }
    
    var valueText: String {
        if likes == 0 && comments == 0 {
            return ""
        } else if likes != 0 && comments == 0 {
            return String(likes)
        } else if likes == 0 && comments != 0 {
            return String(comments) + " " + commentText
        } else {
            return String(likes) + AppStrings.Characters.dot + String(comments) + " " + commentText
        }
    }
    
    var reference: ReferenceKind? {
        if let reference = post.reference {
            return reference
        } else {
            return nil
        }
    }
    
    
    var time: String {
        return edited ? timestamp + evidence + AppStrings.Characters.dot + AppStrings.Miscellaneous.evidence + AppStrings.Characters.dot : timestamp + evidence  + AppStrings.Characters.dot
    }

    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: post.timestamp.dateValue(), to: Date()) ?? ""
    }

    var evidence: String {
        if let _ = post.reference {
            return AppStrings.Characters.dot + AppStrings.Miscellaneous.evidence
        } else {
            return ""
        }
    }
    
    var privacyImage: UIImage {
        switch post.privacy {
        case .regular: return post.privacy.image.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        }
    }
    
    init(post: Post) {
        self.post = post
    }
}
