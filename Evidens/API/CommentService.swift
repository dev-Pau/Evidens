//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct CommentService {
    
    static func uploadPostComment(comment: String, post: Post, user: User, type: Comment.CommentType, completion: @escaping([String]) -> Void) {
        let isAuthor = (post.ownerUid == user.uid) ? true : false
        
        
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document()
            let data: [String: Any] = ["uid": user.uid as Any,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date()),
                                       "isAuthor": isAuthor]
            commentRef.setData(data) { _ in
                
                completion([commentRef.documentID, post.postId])
                //Update number of comments for the post
                COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document()
            let data: [String: Any] = ["uid": user.uid as Any,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date()),
                                       "isAuthor": isAuthor]
            commentRef.setData(data) { _ in

                completion([commentRef.documentID, post.postId])
               // COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
            }
        }
    }
    
    static func uploadCaseComment(comment: String, clinicalCase: Case, user: User, type: Comment.CommentType, completion: @escaping([String]) -> Void) {
        let isAuthor = (clinicalCase.ownerUid == user.uid) ? true : false
        
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document()

            let data: [String: Any] = ["uid": user.uid as Any,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date()),
                                       "isAuthor": isAuthor]
        
            commentRef.setData(data) { _ in
                //Update recent comments for the user
                completion([commentRef.documentID, clinicalCase.caseId])
                
                //Update number of comments for the case
                COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document()
            let data: [String: Any] = ["uid": user.uid as Any,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date()),
                                       "isAuthor": isAuthor]
            commentRef.setData(data) { _ in

                completion([commentRef.documentID, clinicalCase.caseId])
               // COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
            }
        }
    }
    
    static func uploadAnonymousComment(comment: String, clinicalCase: Case, user: User, type: Comment.CommentType, completion: @escaping([String]) -> Void) {
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document()

            let data: [String: Any] = ["uid": user.uid as Any,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date()),
                                       "anonymous": true,
                                       "isAuthor": true]
            
            commentRef.setData(data) { _ in
                //Update recent comments for the user
                completion([commentRef.documentID, clinicalCase.caseId])
                
                //Update number of comments for the case
                COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document()
            let data: [String: Any] = ["uid": user.uid as Any,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date()),
                                       "anonymous": true,
                                       "isAuthor": true]
            
            commentRef.setData(data) { _ in
                //Update recent comments for the user
                completion([commentRef.documentID, clinicalCase.caseId])
                
                //Update number of comments for the case
                //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
            }
        }
        
        
        /*

         */
    }
    
    static func fetchComments(forPost post: Post, forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        
        switch type {
        case .regular:
            let query = COLLECTION_POSTS.document(post.postId).collection("comments")
                .order(by: "timestamp", descending: false)
            
            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let comments = documents.map({ Comment(dictionary: $0.data())})
                completion(comments)
                
            }
        case .group:
            //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-likes")
            let query = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").order(by: "timestamp", descending: false)
            
            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let comments = documents.map({ Comment(dictionary: $0.data())})
                completion(comments)
                
            }
        }
    }
    
    
    static func fetchCaseComments(forCase clinicalCase: Case, forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        switch type {
        case .regular:
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
                .order(by: "timestamp", descending: false)
            
            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let comments = documents.map({ Comment(dictionary: $0.data())})
                completion(comments)
            }
        case .group:
            let query = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: false)
            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let comments = documents.map({ Comment(dictionary: $0.data())})
                completion(comments)
            }
        }
        
    }
    
  
    static func fetchNumberOfCommentsForPost(post: Post, type: Comment.CommentType, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").count
            commentRef.getAggregation(source: .server) { snaphsot, _ in
                //guard let snaphsot = snaphsot else { return }
                if let comments = snaphsot?.count {
                    completion(comments.intValue)
                }
            }

        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").count
            commentRef.getAggregation(source: .server) { snaphsot, _ in
                //guard let snaphsot = snaphsot else { return }
                if let comments = snaphsot?.count {
                    completion(comments.intValue)
                }
            }
        }
    }
    
    static func fetchNumberOfCommentsForCase(clinicalCase: Case, type: Comment.CommentType, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").count
            commentRef.getAggregation(source: .server) { snaphsot, _ in
                //guard let snaphsot = snaphsot else { return }
                if let comments = snaphsot?.count {
                    completion(comments.intValue)
                }
            }

        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").count
            commentRef.getAggregation(source: .server) { snaphsot, _ in
                //guard let snaphsot = snaphsot else { return }
                if let comments = snaphsot?.count {
                    completion(comments.intValue)
                }
            }
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
