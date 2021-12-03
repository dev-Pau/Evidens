//
//  PostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/11/21.
//

import UIKit

struct PostViewModel {
    var post: Post
    
    var postText: String {
        return post.postText
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
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
    
    //var timestamp: String {
     //   return post.timestamp
    //}
    
    var likesLabelText: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    init(post: Post) {
        self.post = post
    }
}
