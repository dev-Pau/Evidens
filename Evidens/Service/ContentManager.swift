//
//  ContentChangesManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/8/23.
//

import Foundation

class ContentManager {
    
    static let shared = ContentManager()
  
    func likePostChange(postId: String, didLike: Bool) {
        let postChange = PostLikeChange(postId: postId, didLike: didLike)
        NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.postLike), object: postChange)
    }
}
