//
//  Search.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/3/23.
//

import UIKit

/// An enum mapping all the topics to search for.
enum SearchTopics: Int, CaseIterable {
    case featured, people, posts, cases
    
    var title: String {
        switch self {
        case .featured: return AppStrings.Search.Topics.featured
        case .people: return AppStrings.Search.Topics.people
        case .posts: return AppStrings.Search.Topics.posts
        case .cases: return AppStrings.Search.Topics.cases
        }
    }
}

