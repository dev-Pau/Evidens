//
//  EditPostViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/7/23.
//

import UIKit
import LinkPresentation

/// The viewModel for a EditPost.
class EditPostViewModel {
    var post: Post
    
    private(set) var postText: String
    private(set) var hashtags: [String]?
    
    private(set) var links = [String]()
    private(set) var linkLoaded = false
    private(set) var linkMetadata: LPLinkMetadata?

    init(post: Post) {
        self.post = post
        self.postText = post.postText
    }
    
    var postId: String {
        return post.postId
    }
    
    var kind: PostKind {
        if post.kind == .image {
            return .image
        } else if linkLoaded {
            return .link
        } else {
            return .text
        }
    }
    
    func edit(_ postText: String) {
        self.postText = postText
    }
    
    func set(_ hashtags: [String]) {
        self.hashtags = hashtags.map { $0.lowercased() }
    }
    
    func setLinks(_ links: [String]) {
        self.links = links
    }
    
    func set(_ linkLoaded: Bool) {
        self.linkLoaded = linkLoaded
    }
    
    func set(_ linkMetadata: LPLinkMetadata?) {
        self.linkMetadata = linkMetadata
    }
    
    func addLink(_ links: [String], completion: @escaping(LPLinkMetadata?) -> Void) {
        
        if links.first != self.links.first {
            self.links = links
            
            if let link = links.first {
                loadLink(link) { [weak self] metadata in
                    guard let strongSelf = self else { return }
                    if let metadata, metadata.imageProvider != nil {
                        
                        strongSelf.linkLoaded = true
                        strongSelf.linkMetadata = metadata
                        completion(metadata)
                        
                    } else {
                        strongSelf.linkLoaded = false
                        strongSelf.linkMetadata = nil
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

