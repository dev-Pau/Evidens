//
//  NotificationPreferences.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

/// The model for a NotificationPreference.
struct NotificationPreference {
    var enabled: Bool
    
    var reply: Bool
    var like: Bool
    var connection: Bool
    var message: Bool
    var trackCase: Bool
    
    var replyTarget: NotificationTarget
    var likeTarget: NotificationTarget
    
    init(dictionary: [String: Any]) {
        self.enabled = dictionary["enabled"] as? Bool ?? false
        
        self.connection = dictionary["connection"] as? Bool ?? false
        self.message = dictionary["message"] as? Bool ?? false
        self.trackCase = dictionary["trackCase"] as? Bool ?? false
        
        if let replyData = dictionary["reply"] as? [String: Any] {
            self.reply = replyData["value"] as? Bool ?? false
            self.replyTarget = NotificationTarget(rawValue: replyData["target"] as? Int ?? 0) ?? .anyone
        } else {
            self.reply = false
            self.replyTarget = .anyone
        }
        
        if let likeData = dictionary["like"] as? [String: Any] {
            self.like = likeData["value"] as? Bool ?? false
            self.likeTarget = NotificationTarget(rawValue: likeData["target"] as? Int ?? 0) ?? .anyone
        } else {
            self.like = false
            self.likeTarget = .anyone
        }
    }
    
    mutating func update<T>(keyPath: WritableKeyPath<NotificationPreference, T>, value: T) {
        self[keyPath: keyPath] = value
    }
}
