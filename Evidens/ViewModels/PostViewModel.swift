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
        return post.type.postType
    }
    
    var postText: String {
        return post.postText
    }
    
    var comments: Int {
        return post.numberOfComments
    }
    
    var commentsLabelText: String {
        if post.numberOfComments > 1 {
            return "\(post.numberOfComments) comments"
        }
        else if post.numberOfComments == 1 {
            return "\(post.numberOfComments) comment"
        }
        else {
            return ""
        }
    }
    
    var shares: Int {
        return post.numberOfShares
    }
    
    var shareLabelText: String {
        if post.numberOfShares > 1 {
            return "\(post.numberOfShares) shares"
        }
        else if post.numberOfShares == 1 {
            return "\(post.numberOfShares) share"
        }
        else {
            return ""
        }
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
    }
    
    var postImageUrl: [URL] {
        post.postImageUrl.map { image in
            URL(string: image)!
        }
    }
    
    
    
    var firstName: String {
        return post.ownerFirstName
    }
    
    var lastName: String {
        return post.ownerLastName
    }
    
    
    
    var fullName: String {
        return post.ownerFirstName + " " + post.ownerLastName
    }
    
    var likes: Int {
        return post.likes
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? UIColor(rgb: 0xEC7480) : UIColor(rgb: 0x000000)
    }
    
    var likeButtonImage: UIImage? {
        let imageName = post.didLike ? "heart.fill" : "heart"
        return UIImage(systemName: imageName)
    }
    
    var bookMarkImage: UIImage? {
        let imageName = post.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(systemName: imageName)
    }
    
    var likesLabelText: String {
        if post.likes > 0 {
            return "\(post.likes)"
        } else {
            return ""
        }
    }
    
    var isLikesHidden: Bool {
        if post.likes == 0 {
            return true
        } else {
            return false
        }
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: post.timestamp.dateValue(), to: Date())
    }
    
    init(post: Post) {
        self.post = post
    }
    
    //Return the height for dynamic cell height
    func size(forWidth width: CGFloat) ->CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = post.postText
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
