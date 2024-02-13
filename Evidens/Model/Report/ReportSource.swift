//
//  ReportSource.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// An enum mapping the source of a Report.
enum ReportSource: Int {
    case post, clinicalCase, comment, user
    
    var name: String {
        switch self {
        case .post: return "posts"
        case .clinicalCase: return "cases"
        case .comment: return "comments"
        case .user: return "users"
        }
    }
}
