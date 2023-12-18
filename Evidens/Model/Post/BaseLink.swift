//
//  BaseLink.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/12/23.
//

import UIKit

class BaseLink: NSDiscardableContent {

    let title: String
    let url: String
    let image: UIImage
    
    init(title: String, url: String, image: UIImage) {
        self.title = title
        self.url = url
        self.image = image
    }
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
        
    }
    
    func discardContentIfPossible() {
        
    }
    
    func isContentDiscarded() -> Bool {

        return false
    }
}
