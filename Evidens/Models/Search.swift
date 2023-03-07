//
//  Search.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/3/23.
//

import UIKit

struct Search {
    
    enum Topics: String, CaseIterable {
        case people = "People"
        case posts = "Posts"
        case cases = "Cases"
        case groups = "Groups"
        case jobs = "Jobs"
        // ["People", "Posts", "Cases", "Groups", "Jobs"]
    }
}
