//
//  NewViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/23.
//

import UIKit
import Firebase

struct NewViewModel {
    let new: New
    
    init(new: New) {
        self.new = new
    }
    
    var newTitle: String {
        return new.title
    }
    
    var newSummary: String {
        return new.summary
    }
    
    var newAuthor: String {
        return new.author
    }
    
    var mainImageUrl: String {
        return new.mainImageUrl ?? ""
    }
    
    var urlImages: [String] {
        return new.urlImages ?? [""]
    }
    
    var imageCaptions: [String] {
        return new.imageTitles ?? []
    }
    
    var newContent: [String] {
        return new.content
    }
    
    var newsCategory: String {
        return new.category
    }
    
    var readTime: Int {
        return new.readTime
    }
    
    /*

     let timestamp: Timestamp

     */
}
