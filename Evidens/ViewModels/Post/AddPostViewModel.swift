//
//  UploadPostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/6/22.
//

import UIKit
import LinkPresentation

protocol AddPostViewModelDelegate {
    var postIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
}

struct AddPostViewModel: AddPostViewModelDelegate {
    
    var text: String?
    var reference: Reference?
    var images = [UIImage]()
    
    var links = [String]()
    var linkLoaded = false
    
    var linkMetadata: LPLinkMetadata?
    
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
    
    var hasLinks: Bool {
        return !links.isEmpty
    }

    var postIsValid: Bool {
        return hasText
    }
    
    var buttonBackgroundColor: UIColor {
        return postIsValid ? primaryColor : primaryColor.withAlphaComponent(0.5)
    }
    
    var kind: PostKind {
        if hasImages {
            return.image
        } else if linkLoaded {
            return .link
        } else {
            return .text
        }
    }
    
    var hasReference: Bool {
        return reference != nil
    }
    
    mutating func addLink(_ links: [String], completion: @escaping(LPLinkMetadata?) -> Void) {
        
        if links.first != self.links.first {
            self.links = links
            
            if let link = links.first {
                loadLink(link) { metadata in
                    if let metadata, metadata.imageProvider != nil {
                        completion(metadata)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func loadLink(_ link: String, completion: @escaping(LPLinkMetadata?) -> Void) {
        guard let url = URL(string: link) else { return }
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { metadata, error in
            
            guard let data = metadata, error == nil, data.title != nil else {
                completion(nil)
                return
            }
        
            completion(data)
        }
    }
}
