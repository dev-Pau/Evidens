//
//  PrimaryMessageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/10/23.
//

import Foundation

/// The viewModel for a primary message.
class PrimaryMessageViewModel {
    
    var conversation: Conversation

    var user: User?
    var message: Message?
    
    var connection: ConnectPhase?
    
    var preview: Bool = false
    var presented: Bool = false

    var newConversation: Bool?
    
    var messages = [Message]()

    var isShowingEmoji: Bool = false
    
    var firstTime: Bool = true

    
    init(conversation: Conversation, user: User? = nil, preview: Bool? = false, presented: Bool? = false) {
        self.conversation = conversation
        self.user = user
        self.preview = preview ?? false
        self.presented = presented ?? false
        
        self.messages = DataService.shared.getMessages(for: conversation)
    }

    init(conversation: Conversation, message: Message, preview: Bool? = false) {
        self.conversation = conversation
        self.message = message
        self.preview = preview ?? false
    }
    
    func getPhase(completion: @escaping() -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            connection = .connected
            completion()
            return
        }
        
        ConnectionService.getConnectionPhase(uid: conversation.userId) { [weak self] connection in
            guard let strongSelf = self else { return }
            strongSelf.connection = connection.phase
            completion()
        }
    }
}
