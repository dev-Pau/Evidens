//
//  CaseRevision.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/23.
//

import Firebase

struct CaseRevision {
    let title: String?
    let content: String
    let kind: CaseRevisionKind
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? ""
        self.content = dictionary["content"] as? String ?? ""
        self.kind = CaseRevisionKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .clear
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp()
    }
    
    init(title: String? = nil, content: String, kind: CaseRevisionKind) {
        self.title = title
        self.content = content
        self.kind = kind
        self.timestamp = Timestamp()
    }
}
