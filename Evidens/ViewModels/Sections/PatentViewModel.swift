//
//  PatentViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/8/23.
//

import Foundation

struct PatentViewModel {
    
    private(set) var id: String?
    private(set) var title: String?
    private(set) var code: String?
    private(set) var uids: [String]?
    
    private(set) var users = [User]()
    
    var isValid: Bool {
        return title != nil && code != nil && uids != nil
    }
    
    mutating func set(patent: Patent?) {
        if let patent {
            self.id = patent.id
            self.title = patent.title
            self.code = patent.code
            self.uids = patent.uids
            self.users = patent.users
        }
    }
    
    mutating func set(title: String?) {
        self.title = title
    }
    
    mutating func set(code: String?) {
        self.code = code
    }
    
    mutating func set(users: [User]) {
        self.uids = users.map { $0.uid! }
        self.users = users
    }
    
    
    var patent: Patent? {
        guard let id = id, let title = title, let code = code, let uids = uids else {
            return nil
        }
        
        return Patent(id: id, title: title, code: code, uids: uids)
    }
}
