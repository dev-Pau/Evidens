//
//  ProfileSection.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/9/23.
//

import Foundation

/// An enum representing different types of content in a profile.
enum ProfileSection: CaseIterable {
    case cases, posts, reply
    
    var title: String {
        switch self {
            
        case .cases: return AppStrings.Profile.Section.cases
        case .posts: return AppStrings.Profile.Section.post
        case .reply: return AppStrings.Profile.Section.reply
        }
    }
}
