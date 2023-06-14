//
//  MessageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/5/23.
//

import UIKit

/// The view model for the Message.
class MessageViewModel {
    
    let message: Message
    
    /// Creates an instance of the MessageViewModel
    ///
    /// - Parameters:
    ///   - message: The message for the view model.
    init(message: Message) {
        self.message = message
    }
    
    var isSender: Bool {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return false }
        return message.senderId == uid
    }
    
    var kind: MessageKind {
        return message.kind
    }
    
    var text: String {
        return message.text
    }
    
    var date: String {
        return formatDateString(for: message.sentDate)
    }
   
    var imageUrl: URL? {
        guard let imagePath = message.image else { return nil }
        if let url = URL(string: imagePath) {
            return url
        } else {
            return nil
        }
    }
    
    var phase: String {
        switch message.phase {
        case .read:
            return ""
        case .sent:
            return ""
        case .sending:
            return " · Sending..."
        case .failed:
            return " · Not Delivered"
        case .unread:
            return ""
        }
    }
    
    var time: String {
        return formatHourMinuteString(for: message.sentDate) + phase
    }
    
    var failed: Bool {
        return message.phase == .failed
    }
    
    func formatDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        let isToday = calendar.isDateInToday(date)
        let isYesterday = calendar.isDateInYesterday(date)
        let isWithinThisWeek = calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if isToday {
            formatter.dateFormat = "'Today'"
            return formatter.string(from: date)
        } else if isYesterday {
            formatter.dateFormat = "'Yesterday'"
            return formatter.string(from: date)
        } else if isWithinThisWeek {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "EEEE, d MMM"
            return formatter.string(from: date)
        }
    }
    
    var emoji: Bool {
        return message.text.containsEmojiOnly
    }
    
    var size: CGFloat {
        let count = text.count
        if count == 1 {
            return 50.0
        } else if count == 2 {
            return 40.0
        } else if count == 3 {
            return 30.0
        } else {
            return 16.0
        }
    }
    
    var sentDateString: String {
        let sentDate = message.sentDate
        
        let calendar = Calendar.current
        let currentDate = Date()
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(sentDate) {
            return sentDate.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(sentDate) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: sentDate, to: currentDate).day, daysAgo < 7 {
            let weekday = calendar.component(.weekday, from: sentDate)
            let weekdaySymbol = formatter.weekdaySymbols[weekday - 1]
            return weekdaySymbol
        } else {
            return sentDate.formatted(date: .abbreviated, time: .omitted)
        }
    }

    func formatHourMinuteString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
