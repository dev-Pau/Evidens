//
//  PostService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/21.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadPost(post: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["post": post, "timestamp": Timestamp(date: Date()), "likes": 0, "ownerUid": uid] as [String : Any]
        
        COLLECTION_POSTS.addDocument(data: data, completion: completion)
    }
    
    static func fetchPosts() {
        COLLECTION_POSTS.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { doc in
                print("DEBUG: Doc data is \(doc.data())")
            }
            
        }
    }
}
