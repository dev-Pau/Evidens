//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct CommentService {
    
    static func uploadComment(comment: String, post: Post, user: User, completion: @escaping(String) -> Void) {

        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "firstName": user.firstName as Any,
                                   "category": user.category.userCategoryString as Any,
                                   "speciality": user.speciality as Any,
                                   "profession": user.profession as Any,
                                   "lastName": user.lastName as Any,
                                   "profileImageUrl": user.profileImageUrl as Any]
        
        let caseRef = COLLECTION_POSTS.document(post.postId).collection("comments").addDocument(data: data, completion: { _ in
            print("case uploaded")
        })
        
        completion(caseRef.documentID)
                                                                                         
        //Update number of comments for the post
        COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
    }
    
    static func fetchComments(forPost postID: String, completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        
        let query = COLLECTION_POSTS.document(postID).collection("comments")
            .order(by: "timestamp", descending: false)
        
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
    
    static func uploadCaseComment(comment: String, clinicalCase: Case, user: User, completion: @escaping(String) -> Void) {

        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "timestamp": Timestamp(date: Date()),
                                   "firstName": user.firstName as Any,
                                   "category": user.category.userCategoryString as Any,
                                   "speciality": user.speciality as Any,
                                   "profession": user.profession as Any,
                                   "lastName": user.lastName as Any,
                                   "profileImageUrl": user.profileImageUrl as Any]
        
        let caseRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").addDocument(data: data, completion: { error in
            print("comment case uploaded")
        })
        //Update recent comments for the user
        completion(caseRef.documentID)
        
        //Update number of comments for the case
        COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
    }
    
    static func fetchCaseComments(forCase caseID: String, completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        
        let query = COLLECTION_CASES.document(caseID).collection("comments")
            .order(by: "timestamp", descending: false)
        
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
