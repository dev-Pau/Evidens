//
//  Publication.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// The model for a Publication.
struct Publication {
    let id: String
    let title: String
    let url: String
    let timestamp: TimeInterval
    let uids: [String]
    
    var users = [User]()
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? TimeInterval()
        self.uids = dictionary["uids"] as? [String] ?? []
    }
    
    init(id: String, title: String, url: String, timestamp: TimeInterval, uids: [String]) {
        self.id = id
        self.title = title
        self.url = url
        self.timestamp = timestamp
        self.uids = uids
    }
}
