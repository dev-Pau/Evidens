//
//  MessageSearch.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/6/23.
//

import Foundation

/// An enum mapping the search options for the messaging feature.
enum MessageSearch: Int, CaseIterable {
    
    case all, conversation, messages
    
    var title: String {
        switch self {
        case .all: return AppStrings.Content.Case.Filter.all
        case .conversation: return AppStrings.Title.conversation
        case .messages: return AppStrings.Title.message
        }
    }
}
