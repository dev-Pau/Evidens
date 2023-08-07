//
//  Experience.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

struct Experience {
    let id: String
    let role: String
    let company: String
    let start: TimeInterval
    var end: TimeInterval?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.role = dictionary["role"] as? String ?? ""
        self.company = dictionary["company"] as? String ?? ""
        self.start = dictionary["start"] as? TimeInterval ?? TimeInterval()
        
        if let end = dictionary["end"] as? TimeInterval {
            self.end = end
        }
    }
    
    init(id: String, role: String, company: String, start: TimeInterval, end: TimeInterval? = nil) {
        self.id = id
        self.role = role
        self.company = company
        self.start = start
        self.end = end
    }
}
