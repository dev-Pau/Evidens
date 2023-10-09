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
    
    func getRecentSearches(completion: @escaping () -> Void) {
        DatabaseManager.shared.fetchRecentMessageSearches { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let searches):
                strongSelf.recentSearches = searches
                strongSelf.dataLoaded = true
                completion()
                
            case .failure(let error):
                if error == .empty {
                    strongSelf.dataLoaded = true
                    completion()
                }
            }
        }
    }
    
    func getMainContent() {
        mainConversations = DataService.shared.getConversations(for: searchedText, withLimit: 3, from: Date())
        
        mainMessages = DataService.shared.getMessages(for: searchedText, withLimit: 3, from: Date())
        
        let uniqueConversationIds = Array(Set(mainMessages.map { $0.conversationId! }))
        mainMessageConversations = DataService.shared.getConversations(for: uniqueConversationIds)
        
        didFetchMainContent = true
    }
    
    func getConversations() {
        conversations = DataService.shared.getConversations(for: searchedText, withLimit: 15, from: Date())
        didFetchConversations = true
    }
    
    func getMessages() {
        messages = DataService.shared.getMessages(for: searchedText, withLimit: 30, from: Date())

        let uniqueConversationIds = Array(Set(messages.map { $0.conversationId! }))

        messageConversations = DataService.shared.getConversations(for: uniqueConversationIds)

        didFetchMessages = true
    }
    
    func getMoreConversations() -> Bool {
        guard let latestConversation = conversations.last, let creationDate = latestConversation.date, !isFetchingMoreConversations else { return false }
        isFetchingMoreConversations = true
        
        let newConversations = DataService.shared.getConversations(for: searchedText, withLimit: 15, from: creationDate)
        
        guard !newConversations.isEmpty else {
            isFetchingMoreConversations = false
            return false
        }
        
        conversations.append(contentsOf: newConversations)
        isFetchingMoreConversations = false
        return true
    }
    
    func getMoreMessages() -> Bool {
        guard let latestMessage = messages.last, !isFetchingMoreMessages else { return false }
        
        isFetchingMoreMessages = true

        let newMessages = DataService.shared.getMessages(for: searchedText, withLimit: 30, from: latestMessage.sentDate)

        guard !newMessages.isEmpty else {
            isFetchingMoreMessages = false
            return false
        }
        
        messages.append(contentsOf: newMessages)

        let uniqueConversationIds = Array(Set(newMessages.map { $0.conversationId! }))

        messageConversations.append(contentsOf: DataService.shared.getConversations(for: uniqueConversationIds))
        
        isFetchingMoreMessages = false
        return true
    }
}
