//
//  New.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/3/23.
//

import UIKit
import Firebase

struct New {
    
    let title: String
    let summary: String
    let author: String
    let timestamp: Timestamp
    
    let mainImageUrl: String?
    let urlImages: [String]?
    let imageTitles: [String]?
    let content: [String]
    
    let category: String
    let readTime: Int
  
     init(dictionary: [String: Any]) {
         self.title = dictionary["title"] as? String ?? ""
         self.summary = dictionary["summary"] as? String ?? ""
         self.author = dictionary["author"] as? String ?? ""
         self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
         
         self.mainImageUrl = dictionary["mainImageUrl"] as? String ?? ""
         self.urlImages = dictionary["urlImages"] as? [String] ?? []
         self.imageTitles = dictionary["urlImages"] as? [String] ?? []
         self.content = dictionary["content"] as? [String] ?? []
         
         self.category = dictionary["category"] as? String ?? ""
         self.readTime = dictionary["readTime"] as? Int ?? 0
     }
}
