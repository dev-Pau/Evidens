//
//  PostVisibility.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/8/23.
//

import Foundation

/// An enum mapping all the post visibility options.
enum PostVisibility: Int {
    
    /*
     
     - Regular: The post is visible and accessible to all users.
     - Deleted: The post has been deleted by the user.
     - Hidden: The post is hidden due to the user's account deactivation or deletion.
     - Disabled: The post has been permanently removed by Evidens.
     
     */
    
    case regular, deleted, hidden, disabled
}
