//
//  CommentViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import UIKit

struct CommentViewModel {
    let comment: Comment
    
    var anonymousComment: Bool {
        return comment.anonymous
    }
    
    var commentOnwerUid: String {
        return comment.uid
    }
    
    var isAuthor: Bool {
        return comment.isAuthor
    }
    
    var profileImageUrl: URL? {
        return URL(string: comment.profileImageUrl)
    }
    
    var fullName: String {
        if anonymousComment {
            return "Anonymous"
        } else {
            return comment.firstName + " " + comment.lastName
        }
    }
    
    var commentText: String {
        return comment.commentText
    }
    
    var speciality: String {
        return comment.speciality
    }
    
    var profession: String {
        return comment.profession
    }
    
    var userIsProfessional: Bool {
        return category == "Professional" ? true : false
    }
    
    var category: String {
        return comment.category
    }
    
    
    func userLabelText() -> NSAttributedString {
        if userIsProfessional {
            let attributedString = NSMutableAttributedString(string: "\(fullName)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            return attributedString
        } else {
            let attributedString = NSMutableAttributedString(string: "\(fullName) · ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: category, attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: primaryColor]))
            return attributedString
        }
    }
     
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: comment.timestamp.dateValue(), to: Date())
    }
    
    
    init(comment: Comment) {
        self.comment = comment
    }
}
