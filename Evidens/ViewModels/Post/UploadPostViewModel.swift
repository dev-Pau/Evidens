//
//  UploadPostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/22.
//

import UIKit

protocol UploadContentViewModel {
    func updateForm()
}

protocol UploadViewModel {
    var postIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
}

struct UploadPostViewModel: UploadViewModel {
    
    var text: String?
    
    var hasText: Bool {
        return text?.isEmpty == false
    }
    
    var hasImage: Bool = false
    var hasPoll: Bool = false
    var hasDocument: Bool = false
    var hasVideo: Bool = false
    
    var postIsValid: Bool {
        if hasText || hasImage || hasPoll || hasDocument || hasVideo {
            return true
        } else {
            return false
        }
    }
    
    var buttonBackgroundColor: UIColor {
        return postIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
}
