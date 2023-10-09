//
//  ConversationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/9/22.
//

import UIKit

/// The view model for the Conversation.
struct ConversationViewModel {
    
    private let conversation: Conversation
    
    /// Creates an instance of the ConversationViewModel.
    ///
    /// - Parameters:
    ///   - conversation: The conversation of the view model.
    init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    var name: String {
        return conversation.name
    }

    func image() -> URL? {
        if let imagePath = conversation.image, let url = URL(string: imagePath) {
            return url
        } else {
            return nil
        }
    }
    
    private var isSender: Bool {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let latestMessage = conversation.latestMessage else { return false }
        return latestMessage.senderId == uid ? true : false
    }
    
    var lastMessage: String {
        guard let latestMessage = conversation.latestMessage else { return "" }
        if latestMessage.phase == .failed {
            return AppStrings.Content.Message.failure
        } else {
            let text = latestMessage.text
            return isSender ? AppStrings.Miscellaneous.you + ": " + text : text
        }
    }
    
    var lastMessageDate: String {
        guard let sentDate = conversation.latestMessage?.sentDate else { return "" }
        
        let calendar = Calendar.current
        let currentDate = Date()
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(sentDate) {
            return sentDate.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(sentDate) {
            return AppStrings.Content.Message.yesterday
        } else if let daysAgo = calendar.dateComponents([.day], from: sentDate, to: currentDate).day, daysAgo < 7 {
            let weekday = calendar.component(.weekday, from: sentDate)
            let weekdaySymbol = formatter.weekdaySymbols[weekday - 1]
            return weekdaySymbol
        } else {
            return sentDate.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    var unreadMessages: Int {
        conversation.unreadMessages ?? 0
    }
    
    var isPinned: Bool {
        conversation.isPinned
    }

    var messageColor: UIColor {
        guard let latestMessage = conversation.latestMessage else { return .clear }
        return latestMessage.isRead ? .secondaryLabel : primaryColor
    }
    
    var pinImage: UIImage {
        return (UIImage(systemName: AppStrings.Icons.fillPin)!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel).rotate(radians: .pi/4))!
    }
}
