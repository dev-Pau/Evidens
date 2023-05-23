//
//  New.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/3/23.
//

import UIKit
import Firebase

/// The model for a New.
struct New {
    
    let title: String
    let summary: String
    let author: String
    let timestamp: Timestamp
    let category: String
    let readTime: Int
    let content: [String]
    let mainImageUrl: String?
    let urlImages: [String]?
    let imageTitles: [String]?
    
    /// Initializes a new instance of a New using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the New data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.summary = dictionary["summary"] as? String ?? ""
        self.author = dictionary["author"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.mainImageUrl = dictionary["mainImageUrl"] as? String ?? ""
        self.urlImages = dictionary["urlImages"] as? [String] ?? []
        self.imageTitles = dictionary["imageTitles"] as? [String] ?? []
        self.content = dictionary["content"] as? [String] ?? []
        self.category = dictionary["category"] as? String ?? ""
        self.readTime = dictionary["readTime"] as? Int ?? 0
    }
}
