//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/8/23.
//

import Foundation

struct Patent {
    let id: String
    let title: String
    let code: String
    let uids: [String]
    
    var users = [User]()
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.code = dictionary["code"] as? String ?? ""
        self.uids = dictionary["uids"] as? [String] ?? []
    }
    
    init(id: String, title: String, code: String, uids: [String]) {
        self.id = id
        self.title = title
        self.code = code
        self.uids = uids
    }
}
