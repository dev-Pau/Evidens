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
        return post.didLike ? pinkColor : .black
    }
    
    var likeButtonImage: UIImage? {
        let imageName = post.didLike ? "heart.fill" : "heart"
        return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
    }
    
    var bookMarkImage: UIImage? {
        let imageName = post.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
    }
    
    var likesLabelText: String {
        if post.likes == 1 {
            return "\(post.likes) like"
        } else if post.likes > 1 {
            return "\(post.likes) likes"
        } else {
            return ""
        }
    }
    
    var profession: String {
        return post.ownerProfession
    }
    
    var category: String {
        return post.ownerCategory
    }
    
    var speciality: String {
        return post.ownerSpeciality
    }
    
    var userInfo: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(profession), ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attributedText.append(NSAttributedString(string: "\(speciality) · ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
        attributedText.append(NSAttributedString(string: category, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: primaryColor]))
        
        return attributedText
    }
    

    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: post.timestamp.dateValue(), to: Date())
    }
    
    var privacyImage: UIImage {
        switch post.privacyOptions.rawValue {
        case 0:
            return UIImage(systemName: "globe.europe.africa.fill")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        case 1:
            return UIImage(systemName: "person.2.fill")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        case 2:
            return UIImage(systemName: "lock.fill")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        default:
            return UIImage(systemName: "globe.europe.africa.fill")!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        }
    }
    
    var sizeOfImage: CGFloat {
        return post.imageHeight
    }
    
    init(post: Post) {
        self.post = post
    }
    
    //Return the height for dynamic cell height
    func size(forWidth width: CGFloat) ->CGSize {
        let label = UILabel()
        label.numberOfLines = 3
        label.text = post.postText
        label.lineBreakMode = .byTruncatingTail
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
