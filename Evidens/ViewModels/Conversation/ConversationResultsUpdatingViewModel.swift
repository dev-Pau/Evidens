//
//  ConversationResultsUpdatingViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/23.
//

import Foundation

class ConversationResultsUpdatingViewModel {
    
    
    var mainConversations = [Conversation]()
    var mainMessages = [Message]()
    var mainMessageConversations = [Conversation]()
    
    var conversations = [Conversation]()
    
    var messages = [Message]()
    var messageConversations = [Conversation]()
    
    var isFetchingMoreConversations: Bool = false
    var isFetchingMoreMessages: Bool = false
    
    var recentSearches = [String]()
    var dataLoaded: Bool = false
    
    var searchedText = ""
    var isScrollingHorizontally = false
    
    var didFetchMainContent = false
    var didFetchConversations = false
    var didFetchMessages = false
    var scrollIndex: Int = 0
    
}
