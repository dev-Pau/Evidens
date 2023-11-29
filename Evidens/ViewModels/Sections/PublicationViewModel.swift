//
//  PublicationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/8/23.
//

import Foundation
import UIKit

struct PublicationViewModel {

    private(set) var id: String?
    private(set) var title: String?
    private(set) var url: String?
    private(set) var timestamp: TimeInterval?
    private(set) var uids: [String]?
    
    private(set) var users = [User]()
    
    var isValid: Bool {
        guard let _ = title, let _ = url, let _ = timestamp, validUrl() else { return false }
        return true
    }
    
    func validUrl() -> Bool {
        guard let url = url, !url.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        let link = url.processWebLink()
        
        if let processedURL = URL(string: link), UIApplication.shared.canOpenURL(processedURL), let host = processedURL.host {
            let trimUrl = host.split(separator: ".")
            
            if let tld = trimUrl.last, String(tld).uppercased().isDomainExtension() {
                return true
            }
        }
        
        return false
    }
    
    mutating func set(publication: Publication?) {
        if let publication {
            self.id = publication.id
            self.title = publication.title
            self.url = publication.url
            self.timestamp = publication.timestamp
            self.uids = publication.uids
            self.users = publication.users
        }
    }
    
    mutating func set(title: String?) {
        self.title = title
    }
    
    mutating func set(url: String?) {
        self.url = url
    }
    
    mutating func set(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }
    
    mutating func set(users: [User]) {
        self.uids = users.map { $0.uid! }
        self.users = users
    }
    
    var publication: Publication? {
        guard let id = id, let title = title, let url = url, let timestamp = timestamp, let uids = uids else {
            return nil
        }
        
        return Publication(id: id, title: title, url: url, timestamp: timestamp, uids: uids)
    }
}
