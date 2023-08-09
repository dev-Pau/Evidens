//
//  UserStats.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/23.
//

import Foundation

/// The model for the UserStats.
struct UserStats {
    private(set) var followers: Int
    private(set) var following: Int
    private(set) var posts: Int
    private(set) var cases: Int
    
    init() {
        self.followers = 0
        self.following = 0
        self.posts = 0
        self.cases = 0
    }
    
    mutating func set(followers: Int) {
        self.followers = followers
    }
    
    mutating func set(following: Int) {
        self.following = following
    }
    
    mutating func set(posts: Int) {
        self.posts = posts
    }
    
    mutating func set(cases: Int) {
        self.cases = cases
    }
}

