//
//  UserFollowChange.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/8/23.
//

import Foundation

/// The model for a change in user follow.
struct UserFollowChange {
    
    let uid: String
    let isFollowed: Bool
    
    init(uid: String, isFollowed: Bool) {
        self.uid = uid
        self.isFollowed = isFollowed
    }
}
