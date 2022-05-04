//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct CommentService {
    
    static func uploadComment(comment: String, post: Post, user: User, completion: @escaping(FirestoreCompletion)) {

        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "firstName": user.firstName as Any,
                                   "lastName": user.lastName as Any,
                                   "profileImageUrl": user.profileImageUrl as Any]
        
        COLLECTION_POSTS.document(post.postId).collection("comments").addDocument(data: data, completion: completion)
        
        //Update number of comments for the post
        COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
        
    }
    
    static func fetchComments(forPost postID: String, completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        
        let query = COLLECTION_POSTS.document(postID).collection("comments")
            .order(by: "timestamp", descending: true)
        
        //Listener to update UI with new comments
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            })
            completion(comments)
        }
    }
}
