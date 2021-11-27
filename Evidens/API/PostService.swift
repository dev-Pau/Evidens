//
//  PostService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/21.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadPost(post: String, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0, "ownerUid": uid,
                    "ownerFirstName": user.firstName,
                    "ownerLastName": user.lastName,
                    "ownerImageUrl": user.profileImageUrl] as [String : Any]
        
        COLLECTION_POSTS.addDocument(data: data, completion: completion)
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            //Mapping that creates an array for each post
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp & user uid
        let query =  COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
            //.order(by: "timestamp", descending: false)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
        
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            //Order posts by timestamp
            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            
            completion(posts)

        }
    }
}
