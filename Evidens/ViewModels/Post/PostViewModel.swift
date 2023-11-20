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
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 22)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        } else {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 22)).withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        }
    }
    
    var bookMarkImage: UIImage? {
        let imageName = post.didBookmark ? AppStrings.Assets.fillBookmark : AppStrings.Assets.bookmark
        let imageColor = post.didBookmark ? primaryColor : .secondaryLabel
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(imageColor)
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
    
    var kind: PostImageKind {
        guard let images = post.imageUrl, !images.isEmpty else {
            fatalError()
        }
        
        if images.count == 1 {
            return .one
        } else if images.count == 2 {
            return .two
        } else if images.count == 3 {
            return .three
        } else {
            return .four
        }
    }
    
    var time: String {
        return edited ? timestamp + evidence + AppStrings.Characters.dot + AppStrings.Miscellaneous.edited + AppStrings.Characters.dot : timestamp + evidence  + AppStrings.Characters.dot
    }

    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return AppStrings.Characters.dot + (formatter.string(from: post.timestamp.dateValue(), to: Date()) ?? "")
    }
    
    var detailedPost: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = .current
        
        let timeString = formatter.string(from: post.timestamp.dateValue())
        
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let dateString = formatter.string(from: post.timestamp.dateValue())

        return timeString + AppStrings.Characters.dot + dateString + evidence
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
