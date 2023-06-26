//
//  NotificationPreferences.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import Foundation

struct NotificationPreference {
    var enabled: Bool
    
    var reply: Bool
    var like: Bool
    var follower: Bool
    var message: Bool
    
    var replyTarget: NotificationTarget
    var likeTarget: NotificationTarget

    init(dictionary: [String: Any]) {
        self.enabled = dictionary["enabled"] as? Bool ?? false
        
        self.reply = dictionary["reply"] as? Bool ?? false
        self.like = dictionary["like"] as? Bool ?? false
        self.follower = dictionary["follower"] as? Bool ?? false
        self.message = dictionary["message"] as? Bool ?? false
        
        self.replyTarget = NotificationTarget(rawValue: dictionary["reply.replyTarget"] as? Int ?? 0) ?? .anyone
        self.likeTarget = NotificationTarget(rawValue: dictionary["like.likeTarget"] as? Int ?? 0) ?? .anyone
    }
    
    #warning("delete this just for testing purposes")
    init(enabled: Bool, reply: Bool, like: Bool, follower: Bool, message: Bool, replyTarget: NotificationTarget, likeTarget: NotificationTarget) {
        self.enabled = enabled
        self.reply = reply
        self.like = like
        self.follower = follower
        self.message = message
        self.replyTarget = replyTarget
        self.likeTarget = likeTarget
    }
}

//let topic: NotificationTopic.fo
//let state: Bool
//let target: NotificationTarget?

/*
 enum NotificationPreferences: Int, CaseIterable {
 case commentsReplies, likes, followers, messages
 }
 */

/*
self.topic = NotificationTopic(rawValue: dictionary["topic"] as? Int ?? 0) ?? .likes
self.state = dictionary["state"] as? Bool ?? false
self.target = NotificationTarget(rawValue: dictionary["target"] as? Int ?? 0)
 */
