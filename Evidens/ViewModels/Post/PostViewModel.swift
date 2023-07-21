//
//  PostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit

struct PostViewModel {
    var post: Post
    
    var postType: Int {
        return post.kind.rawValue
    }
    
    var postText: String {
        return post.postText
    }
    
    var comments: Int {
        return post.numberOfComments
    }
    
    var commentsLabelText: String {
        if comments == 0 {
            return ""
        } else {
            return "\(comments)"
        }
    }

    var postIsEdited: Bool {
        if let edited = post.edited {
            return edited
        } else {
            return false
        }
    }
    
    var postImageUrl: [URL?] {
        guard let imageUrl = post.imageUrl else { return [] }
        let urls = imageUrl.map { URL(string: $0) }
        return urls
    }
    
    var likes: Int {
        return post.likes
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? pinkColor : .secondaryLabel
    }
    
    var likeButtonImage: UIImage? {
        let imageName = post.didLike ? "heart.fill" : "heart"
        if post.didLike {
            return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.systemPink)
        } else {
            return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.secondaryLabel)
        }

    }
    
    var bookMarkImage: UIImage? {
        let imageName = post.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.secondaryLabel)
    }
    
    var bookmarkButtonTintColor: UIColor {
        return .secondaryLabel
    }
    
    var likesLabelText: String {
        if likes == 0 {
            return ""
        } else {
            return "\(post.likes)"
        }
    }
    
    var commentText: String {
        if comments > 1 { return "comments" }
        else { return "comment" }
    }
    
    var likesButtonIsHidden: Bool {
        return likes > 0 ? false : true
    }
    
    var likesCommentsText: String {
        if likes == 0 && comments == 0 {
            return ""
        } else if likes != 0 && comments == 0 {
            return "\(likes)"
        } else if likes == 0 && comments != 0 {
            return "\(comments) \( commentText)"
        } else {
            return "\(likes) • \(comments) \(commentText)"
        }
    }
    
    var postReference: ReferenceKind? {
        if let reference = post.reference {
            return reference
        } else {
            return nil
        }
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: post.timestamp.dateValue(), to: Date())
    }
    
    
    var evidenceString: String {
        if let _ = post.reference {
            return AppStrings.Characters.dot + AppStrings.Miscellaneous.evidence
        } else {
            return ""
        }
    }
    
    var time: String {
        return postIsEdited ? timestampString! + evidenceString + AppStrings.Characters.dot + AppStrings.Miscellaneous.evidence + AppStrings.Characters.dot : timestampString! + evidenceString  + AppStrings.Characters.dot
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
