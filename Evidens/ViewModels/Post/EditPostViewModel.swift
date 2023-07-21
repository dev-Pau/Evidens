//
//  EditPostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/23.
//

import Foundation

class EditPostViewModel {
    
    private let postId: String
    private(set) var post: String
    private(set) var hashtags: [String]?
    
    init(post: String, postId: String) {
        self.post = post
        self.postId = postId
    }

    func edit(_ post: String) {
        self.post = post
    }
    
    func set(_ hashtags: [String]) {
        self.hashtags = hashtags.map { $0.lowercased() }
    }
}

