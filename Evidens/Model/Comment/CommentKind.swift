//
//  CommentKind.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/7/23.
//

import Foundation

enum CommentKind: Int {
    case comment, reply
    
    var title: String {
        switch self { 
        case .comment: return "commented"
        case .reply: return "replied on a comment"
        }
    }
}
