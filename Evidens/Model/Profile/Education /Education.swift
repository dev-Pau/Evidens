//
//  Education.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// The model for an Education.
struct Education {
    
    let id: String
    let school: String
    let kind: String
    let field: String
    let start: TimeInterval
    var end: TimeInterval?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.school = dictionary["school"] as? String ?? ""
        self.kind = dictionary["kind"] as? String ?? ""
        self.field = dictionary["field"] as? String ?? ""
        self.start = dictionary["start"] as? TimeInterval ?? TimeInterval()
        
        if let end = dictionary["end"] as? TimeInterval {
            self.end = end
        }
    }
    
    init(id: String, school: String, kind: String, field: String, start: TimeInterval, end: TimeInterval? = nil) {
        self.id = id
        self.school = school
        self.kind = kind
        self.field = field
        self.start = start
        self.end = end
    }
}
