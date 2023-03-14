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
    
    var readTimeString: String {
        let text = readTime == 1 ? " minute" : " minutes"
        return String(readTime) + text
    }
    
    var timestampString: String? {
        /*
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .day, .weekOfMonth, .month, .year]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: new.timestamp.dateValue(), to: Date())
         */
        let date = new.timestamp.dateValue()
        return date.formatRelativeString()
    }
    
    /*

     let timestamp: Timestamp

     */
}
