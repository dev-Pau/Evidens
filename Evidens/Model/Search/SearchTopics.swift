//
//  Search.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/3/23.
//

import UIKit

/// The model for the Search engine.
struct Search {
    
    /// An enum mapping all the topics to search for.
    enum Topics: String, CaseIterable {
        case people = "People"
        case posts = "Posts"
        case cases = "Cases"
        case groups = "Groups"
        case jobs = "Jobs"
    }
}
