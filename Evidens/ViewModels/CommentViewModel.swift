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
    
    var isTextFromAuthor: Bool {
        return comment.isTextFromAuthor
    }
    
    var isAuthor: Bool {
        return comment.isAuthor
    }
    
    var commentText: String {
        return comment.commentText
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
