//
//  ProfileSection.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/9/23.
//

import Foundation

enum ProfileSection: CaseIterable {
    case posts, cases, reply, about
    
    var title: String {
        switch self {

        case .posts: return AppStrings.Profile.Section.post
        case .cases: return AppStrings.Profile.Section.cases
        case .reply: return AppStrings.Profile.Section.reply
        case .about: return AppStrings.Profile.Section.about
        }
    }
}
