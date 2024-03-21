//
//  PostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit

/// The viewModel for a Post.
struct PostViewModel {
    var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
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
    
    var linkUrl: String? {
        return post.linkUrl
    }
    
    var likes: Int {
        return post.likes
    }
    
    var likeImage: UIImage? {
        let size: CGFloat = UIDevice.isPad ? 29 : 24
        
        let imageName = post.didLike ? AppStrings.Icons.fillHeart : AppStrings.Icons.heart
        if post.didLike {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size - 2)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryColor)
        } else {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size - 2)).withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryGray)
        }
    }
    
    var bookMarkImage: UIImage? {
        let size: CGFloat = UIDevice.isPad ? 25 : 20
        
        let imageName = post.didBookmark ? AppStrings.Assets.fillBookmark : AppStrings.Assets.bookmark
        let imageColor = post.didBookmark ? K.Colors.primaryColor : K.Colors.primaryGray
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: size, height: size)).withTintColor(imageColor)
    }
    
    var likesText: String {
        return likes == 0 ? "" : String(post.likes)
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
            return .one
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
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
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

        return timeString + AppStrings.Characters.dot + dateString
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
}
