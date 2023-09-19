//
//  UploadPostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/22.
//

import UIKit

protocol AddPostViewModelDelegate {
    var postIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
}

struct AddPostViewModel: AddPostViewModelDelegate {
    
    var text: String?
    var reference: Reference?
    var images = [UIImage]()
    var disciplines = [Discipline]()
    var privacy: PostPrivacy
    var hashtags: [String]?
    
    init() {
        self.privacy = .regular
    }
    
    var hasText: Bool {
        return text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    var hasImages: Bool {
        return !images.isEmpty
    }

    var postIsValid: Bool {
        return hasText
    }
    
    var buttonBackgroundColor: UIColor {
        return postIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
    
    var kind: PostKind {
        return PostKind(rawValue: images.count) ?? .plainText
    }
    
    var hasReference: Bool {
        return reference != nil
    }
}
