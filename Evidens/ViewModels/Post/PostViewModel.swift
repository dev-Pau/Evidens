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
        if comments == 0 {
            return ""
        } else {
            return "\(comments)"
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
    
    var postIsEdited: Bool {
        return post.edited
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
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
    }
    
    var bookMarkImage: UIImage? {
        let imageName = post.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
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
            return "\(likes) · \(comments) \(commentText)"
        }
    }
    
    
    var profession: String {
        return post.ownerProfession
    }
    
    var userIsProfessional: Bool {
        return category == "Professional" ? true : false
    }
    
    var category: String {
        return post.ownerCategory
    }
    
    var speciality: String {
        return post.ownerSpeciality
    }
    
    var userInfo: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(profession), ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        if userIsProfessional {
            attributedText.append(NSAttributedString(string: "\(speciality)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
        } else {
            attributedText.append(NSAttributedString(string: "\(speciality) · ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
            attributedText.append(NSAttributedString(string: category, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: primaryColor]))
            
        }
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
}
