//
//  ConversationsViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/9/23.
//

import Foundation

class ConversationsViewModel {
    
    var user: User?
    
    var conversationsLoaded: Bool = false
    var conversations = [Conversation]()
    var pendingConversations = [Conversation]()
    var didLeaveScreen: Bool = false
    
    func loadConversations() {
        // Messages that have not been sent they get updated to failed
        DataService.shared.editPhase()
        // Retrieve conversations from the data service
        conversations = DataService.shared.getConversations()
        conversationsLoaded = true
    }
    
    func getConversations(completion: @escaping(DatabaseError?) -> Void) {
        DatabaseManager.shared.getConversations(conversations: conversations) { [weak self] error in
            guard let strongSelf = self else { return }
            if let _ = error {
                completion(.network)
            } else {
                strongSelf.conversations = DataService.shared.getConversations()
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                completion(nil)
            }
        }
    }
    
    func observeConversations(completion: @escaping () -> Void) {
        // Observe current conversations
        DatabaseManager.shared.observeConversations { [weak self] conversationId in
            guard let strongSelf = self else { return }
            strongSelf.conversations = DataService.shared.getConversations()
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
            completion()
        }
    }
    
    func onDeleteConversation(completion: @escaping () -> Void) {
        DatabaseManager.shared.onDeleteConversation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.conversations = DataService.shared.getConversations()
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
            completion()
        }
    }
}

//MARK: - Miscellaneous

extension ConversationsViewModel {
    
    func sortConversations() {
        // Sort the conversations based on the defined sorting criteria
        conversations.sort { (conversation1, conversation2) -> Bool in
            /*
             If conversation1 is pinned and conversation2 is not pinned,
             conversation1 should come before conversation2
             */
            if conversation1.isPinned && !conversation2.isPinned {
                return true
            }
            
            /*
             If conversation1 is not pinned and conversation2 is pinned,
             conversation1 should come after conversation2
             */
            if !conversation1.isPinned && conversation2.isPinned {
                return false
            }
            
            /*
             If both conversations are pinned or both conversations are not pinned,
             compare their latest message sent dates to determine the order
            */
            return conversation1.latestMessage?.sentDate ?? Date() > conversation2.latestMessage?.sentDate ?? Date()
        }
    }
    
    func conversationExists(for uid: String, completion: @escaping(Bool) -> Void) {
        DataService.shared.conversationExists(for: uid) { [weak self] exists in
            guard let _ = self else { return }
            completion(exists)
        }
    }
}

//MARK: - Edit Operations

extension ConversationsViewModel {
    func edit(conversation: Conversation, set value: Any?, forKey key: String) {
        DataService.shared.edit(conversation: conversation, set: value, forKey: key)
    }
}

//MARK: - Delete Operations

extension ConversationsViewModel {
    //DatabaseManager.shared.deleteConversation(conversation) { [weak self] error in
    func deleteConversation(_ conversation: Conversation, completion: @escaping(DatabaseError?) -> Void) {
        DatabaseManager.shared.deleteConversation(conversation) { [weak self] error in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                DataService.shared.delete(conversation: conversation)
                completion(nil)
            }
        }
    }
}
