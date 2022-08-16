//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct CommentService {
    
    static func uploadPostComment(comment: String, post: Post, user: User, completion: @escaping([String]) -> Void) {

        let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document()
        
        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: Date()),
                                   "firstName": user.firstName as Any,
                                   "category": user.category.userCategoryString as Any,
                                   "speciality": user.speciality as Any,
                                   "profession": user.profession as Any,
                                   "lastName": user.lastName as Any,
                                   "profileImageUrl": user.profileImageUrl as Any]
        
        commentRef.setData(data) { _ in
            
            completion([commentRef.documentID, post.postId])                                                                                
            //Update number of comments for the post
            COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
        }
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
    
    static func uploadCaseComment(comment: String, clinicalCase: Case, user: User, completion: @escaping([String]) -> Void) {
        
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document()

        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: Date()),
                                   "firstName": user.firstName as Any,
                                   "category": user.category.userCategoryString as Any,
                                   "speciality": user.speciality as Any,
                                   "profession": user.profession as Any,
                                   "lastName": user.lastName as Any,
                                   "profileImageUrl": user.profileImageUrl as Any]
        
        
        commentRef.setData(data) { _ in
            //Update recent comments for the user
            completion([commentRef.documentID, clinicalCase.caseId])
            
            //Update number of comments for the case
            COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
        }
    }
    
    static func uploadAnonymousComment(comment: String, clinicalCase: Case, user: User, completion: @escaping([String]) -> Void) {
        
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document()

        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: Date()),
                                   "anonymous": true,
                                   "category": user.category.userCategoryString as Any,
                                   "speciality": user.speciality as Any,
                                   "profession": user.profession as Any]
        
        commentRef.setData(data) { _ in
            //Update recent comments for the user
            completion([commentRef.documentID, clinicalCase.caseId])
            
            //Update number of comments for the case
            COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
        }
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
    
    static func deletePostComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).delete { error in
            if let _ = error {
                print("Error deleting document")
                completion(false)
                return
            }
            print("Comment deleted from firestore")
            COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments - 1])
            completion(true)
        }
    }
    
    static func deleteCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).delete { error in
            if let _ = error {
                print("Error deleting document")
                completion(false)
                return
            }
            print("Comment deleted from firestore")
            COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments - 1])
            completion(true)
        }
    }
    
}
