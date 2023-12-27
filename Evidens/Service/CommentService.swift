//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

/// A service used to interface with FirebaseFirestore for comments.
struct CommentService { }

//MARK: - Delete Operations

extension CommentService {
    
    /// Deletes a comment from a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case from which the comment will be deleted.
    ///   - commentId: The ID of the comment to be deleted.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
    static func deleteComment(forCase clinicalCase: Case, forPath path: [String], forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        var ref = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        ref.document(commentId).updateData(["visible": Visible.deleted.rawValue]) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {

                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
                
            } else {
                DatabaseManager.shared.deleteRecentComment(forCommentId: commentId) { _ in
                    completion(nil)
                }
            }
        }
    }
    
    /// Deletes a reply from a comment on a case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The case from which the reply will be deleted.
    ///   - commentId: The ID of the parent comment that contains the reply.
    ///   - replyId: The ID of the reply to be deleted.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
    static func deleteReply(forCase clinicalCase: Case, forCommentId commentId: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document(replyId).updateData(["visible": Visible.deleted.rawValue]) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {

                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
                
            } else {
                DatabaseManager.shared.deleteRecentComment(forCommentId: replyId) { _ in
                    completion(nil)
                }
            }
        }
    }
    
    /// Deletes a comment from a post.
    ///
    /// - Parameters:
    ///   - post: The post from which the comment will be deleted.
    ///   - id: The ID of the comment to be deleted.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
    static func deleteComment(forPost post: Post, forPath path: [String], forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        var ref = COLLECTION_POSTS.document(post.postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        ref.document(commentId).updateData(["visible": Visible.deleted.rawValue]) { error in
            
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                    
                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
                
            } else {
                DatabaseManager.shared.deleteRecentComment(forCommentId: commentId) { _ in
                    completion(nil)
                }
            }
        }
    }
    
    /// Deletes a reply from a comment on a post.
    ///
    /// - Parameters:
    ///   - post: The post from which the reply will be deleted.
    ///   - commentId: The ID of the parent comment that contains the reply.
    ///   - replyId: The ID of the reply to be deleted.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
    static func deleteReply(forPost post: Post, forCommentId commentId: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").document(replyId).updateData(["visible": Visible.deleted.rawValue]) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {

                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
                
            } else {
                DatabaseManager.shared.deleteRecentComment(forCommentId: replyId) { _ in
                    completion(nil)
                }
            }
        }
    }
}


//MARK: - Write Operations

extension CommentService {
    
    /// Adds a new comment to a clinical case.
    ///
    /// - Parameters:
    ///   - comment: The content of the comment to be added.
    ///   - clinicalCase: The clinical case to which the comment is added.
    ///   - user: The user who is adding the comment.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<Comment, FirestoreError>` parameter, which contains the added comment if successful, or an error if it fails.
    static func addComment(_ comment: String, for clinicalCase: Case, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document()
        
        let anonymous = uid == clinicalCase.uid && clinicalCase.privacy == .anonymous
        
        let date = Date(timeIntervalSinceNow: -2)
        
        var data: [String: Any] = ["uid": uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: date)]
        
        if anonymous {
            data["visible"] = Visible.anonymous.rawValue
        } else {
            data["visible"] = Visible.regular.rawValue
        }
        
        commentRef.setData(data) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                var comment = Comment(dictionary: data)
                
                if anonymous {
                    comment.isAuthor = uid == clinicalCase.uid
                    completion(.success(comment))
                } else {
                    DatabaseManager.shared.addRecentComment(withId: comment.id, withContentId: clinicalCase.caseId, withPath: [], kind: .comment, source: .clinicalCase, date: date) { _ in
                        comment.isAuthor = uid == clinicalCase.uid
                        completion(.success(comment))
                    }
                }
            }
        }
    }
    
    /// Adds a new comment to a post.
    ///
    /// - Parameters:
    ///   - comment: The content of the comment to be added.
    ///   - post: The post to which the comment is added.
    ///   - user: The user who is adding the comment.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<Comment, FirestoreError>` parameter, which contains the added comment if successful, or an error if it fails.
    static func addComment(_ comment: String, for post: Post, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document()
        
        let date = Date(timeIntervalSinceNow: -2)
        
        let data: [String: Any] = ["uid": uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "visible": Visible.regular.rawValue,
                                   "timestamp": Timestamp(date: date)]
        
        commentRef.setData(data) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                var comment = Comment(dictionary: data)
                DatabaseManager.shared.addRecentComment(withId: comment.id, withContentId: post.postId, withPath: [], kind: .comment, source: .post, date: date) { _ in
                    comment.edit(uid == post.uid)
                    completion(.success(comment))
                }
            }
        }
    }
    
    /// Likes a case comment and updates the user's comment likes.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case containing the comment.
    ///   - id: The ID of the comment to be liked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func likeCaseComment(forId caseId: String, forPath path: [String], forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        var ref = COLLECTION_CASES.document(caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let likeRef = ref.document(commentId).collection("likes").document(uid)
        
        
        dispatchGroup.enter()
        likeRef.setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(caseId).collection("comment-likes").document(commentId).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    
    /// Unlikes a case comment and updates the user's comment likes.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case containing the comment.
    ///   - id: The ID of the comment to be unliked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func unlikeCaseComment(forId caseId: String, forPath path: [String], forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        var ref = COLLECTION_CASES.document(caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let likeRef = ref.document(commentId).collection("likes").document(uid)
        
        
        dispatchGroup.enter()
        likeRef.delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(caseId).collection("comment-likes").document(commentId).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    /// Likes a post comment and updates the user's comment likes.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post containing the comment.
    ///   - path: An array of string identifiers representing the path to the comment within nested collections.
    ///   - commentId: The ID of the comment to be liked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func likePostComment(forId postId: String, forPath path: [String], forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        var ref = COLLECTION_POSTS.document(postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let likeRef = ref.document(commentId).collection("likes").document(uid)
        
        dispatchGroup.enter()
        likeRef.setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(postId).collection("comment-likes").document(commentId).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    /// Unlikes a post comment and removes the like from the user's comment likes.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post containing the comment.
    ///   - path: An array of string identifiers representing the path to the comment within nested collections.
    ///   - commentId: The ID of the comment to be unliked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func unlikePostComment(forId postId: String, forPath path: [String], forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        
        var ref = COLLECTION_POSTS.document(postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let likeRef = ref.document(commentId).collection("likes").document(uid)
        
        dispatchGroup.enter()
        likeRef.delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(postId).collection("comment-likes").document(commentId).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    /// Adds a reply to a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - reply: The text of the reply to be added.
    ///   - commentId: The ID of the parent comment to which the reply will be added.
    ///   - clinicalCase: The clinical case where the comment and reply will be added.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a single parameter of type `Result<Comment, FirestoreError>`.
    ///                 The result will be either `.success` with the added `Comment` object,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    ///
    static func addReply(_ text: String, path: [String], clinicalCase: Case, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var ref = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let commentRef = ref.document()
        
        let anonymous = uid == clinicalCase.uid && clinicalCase.privacy == .anonymous
        
        let date = Date(timeIntervalSinceNow: -2)
        
        var data: [String: Any] = ["uid": uid,
                                   "comment": text,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: date)]
        
        if anonymous {
            data["visible"] = Visible.anonymous.rawValue
        } else {
            data["visible"] = Visible.regular.rawValue
        }
        
        commentRef.setData(data) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                var comment = Comment(dictionary: data)
                
                if uid == clinicalCase.uid && clinicalCase.privacy == .anonymous {
                    comment.edit(uid == clinicalCase.uid)
                    completion(.success(comment))
                } else {
                    DatabaseManager.shared.addRecentComment(withId: comment.id, withContentId: clinicalCase.caseId, withPath: path, kind: .reply, source: .clinicalCase, date: date) { _ in
                        comment.edit(uid == clinicalCase.uid)
                        completion(.success(comment))
                    }
                }
            }
        }
    }
    
    /// Add a reply to a post comment.
    ///
    /// - Parameters:
    ///   - text: The reply text to be added.
    ///   - commentId: The ID of the parent comment for which the reply belongs.
    ///   - post: The post to which the comment belongs.
    ///   - user: The user creating the reply.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a single parameter of type `Result<Comment, FirestoreError>`.
    ///                 The result will be either `.success` with the added `Comment` object,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func addReply(_ text: String, path: [String], post: Post, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var ref = COLLECTION_POSTS.document(post.postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let commentRef = ref.document()
        
        let date = Date(timeIntervalSinceNow: -2)
        
        let data: [String: Any] = ["uid": uid,
                                   "comment": text,
                                   "id": commentRef.documentID,
                                   "visible": Visible.regular.rawValue,
                                   "timestamp": Timestamp(date: date)]
        
        commentRef.setData(data) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.failure(.notFound))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                var comment = Comment(dictionary: data)
                
                DatabaseManager.shared.addRecentComment(withId: comment.id, withContentId: post.postId, withPath: path, kind: .reply, source: .post, date: date) { _ in
                    comment.edit(uid == post.uid)
                    completion(.success(comment))
                }
            }
        }
    }
}

// MARK: - Fetch Operations

extension CommentService {

    /// Fetches post comments for a given post.
    ///
    /// - Parameters:
    ///   - post: The post for which to fetch the comments.
    ///   - lastSnapshot: The last snapshot from which to start the query. Pass nil to start from the beginning.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<QuerySnapshot, FirestoreError>` parameter, which contains the fetched query snapshot if successful, or an error if it fails.
    static func fetchPostComments(forPost post: Post, forPath path: [String], lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        
        if lastSnapshot == nil {
            
            var query = COLLECTION_POSTS.document(post.postId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }

            query.order(by: "timestamp", descending: true).limit(to: 15).getDocuments { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(.notFound))
                        return
                    }
                    
                    guard snapshot.documents.last != nil else {
                        completion(.success(snapshot))
                        return
                    }
                    completion(.success(snapshot))
                }
            }
            
        } else {
            var query = COLLECTION_POSTS.document(post.postId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }

            query.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(.notFound))
                        return
                    }
                    
                    guard snapshot.documents.last != nil else {
                        completion(.success(snapshot))
                        return
                    }

                    completion(.success(snapshot))
                }
            }
        }
    }

    /// Fetches replies for a comment within a post.
    ///
    /// - Parameters:
    ///   - post: The Post object for which replies are being fetched.
    ///   - path: The array representing the path to the comment for which replies are being fetched.
    ///   - lastSnapshot: An optional parameter representing the last document snapshot in case of paginated results.
    ///   - completion: A completion block that is called with the result of the query.
    static func fetchRepliesForPostComment(forPost post: Post, forPath path: [String], lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            var query = COLLECTION_POSTS.document(post.postId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }

            query.order(by: "timestamp", descending: true).limit(to: 15).getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
                
            }
            
        } else {
            
            var query = COLLECTION_POSTS.document(post.postId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }

            query.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    /// Fetches a reply comment for a post at the specified path.
    ///
    /// - Parameters:
    ///   - post: The Post object for which the reply comment is being fetched.
    ///   - path: The array representing the path to the reply comment.
    ///   - completion: A completion block that is called with the result of the query.
    static func fetchReply(forPost post: Post, forPath path: [String], completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        var query = COLLECTION_POSTS.document(post.postId)
        
        for id in path {
            query = query.collection("comments").document(id)
        }
        
        query.getDocument { snapshot, error in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.unknown))
                    return
                }
                
                let comment = Comment(dictionary: data)

                let basePath = Array(path.dropLast())
                getPostCommentValuesFor(forPost: post, forPath: basePath, forComment: comment) { value in

                    completion(.success(value))
                }
            }
        }
    }
   
    /// Fetches case comments for a given clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case for which to fetch the comments.
    ///   - lastSnapshot: The last snapshot from which to start the query. Pass nil to start from the beginning.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<QuerySnapshot?, FirestoreError>` parameter, which contains the fetched query snapshot if successful, or an error if it fails.
    static func fetchCaseComments(forCase clinicalCase: Case, forPath path: [String], lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
              
            var query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }

            query.order(by: "timestamp", descending: true).limit(to: 15).getDocuments { snapshot, error in

                if let error {
                    let nsError = error as NSError
                    let errCode = FirestoreErrorCode(_nsError: nsError)
                    
                    switch errCode.code {

                    case .notFound:
                        completion(.failure(.notFound))
                    default:
                        completion(.failure(.unknown))
                    }
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                completion(.success(snapshot))
            }
        } else {
            
            var query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }
            
            query.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(.notFound))
                        return
                    }
                    
                    guard snapshot.documents.last != nil else {
                        completion(.success(snapshot))
                        return
                    }
                    completion(.success(snapshot))
                }
            }
        }
    }
    
    /// Fetches a reply comment for a clinical case at the specified path.
    ///
    /// - Parameters:
    ///   - clinicalCase: The Case object for which the reply comment is being fetched.
    ///   - path: The array representing the path to the reply comment.
    ///   - completion: A completion block that is called with the result of the query.
    static func fetchReply(forCase clinicalCase: Case, forPath path: [String], completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        var query = COLLECTION_CASES.document(clinicalCase.caseId)
        
        for id in path {
            query = query.collection("comments").document(id)
        }
        
        query.getDocument { snapshot, error in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.unknown))
                    return
                }
                
                let comment = Comment(dictionary: data)

                let basePath = Array(path.dropLast())
                
                getCaseCommentValuesFor(forCase: clinicalCase, forPath: basePath, forComment: comment) { value in

                    completion(.success(value))
                }
            }
        }
    }
    
    /// Fetches replies for a specific comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case for which the comment belongs.
    ///   - commentId: The ID of the comment for which replies will be fetched.
    ///   - lastSnapshot: The last snapshot of the previous batch of replies. Pass `nil` to fetch the first batch.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the fetched `QuerySnapshot`,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchRepliesForCaseComment(forClinicalCase clinicalCase: Case, forPath path: [String], lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            var query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }
            
            query.order(by: "timestamp", descending: false).limit(to: 15).getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
                
            }
        } else {
            
            var query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
            
            for id in path {
                query = query.document(id).collection("comments")
            }
            
            query.order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    /// Fetches the raw comments for the given notifications.
    ///
    /// - Parameters:
    ///   - notifications: An array of `Notification` objects for which raw comments are to be fetched.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[Comment], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `Comment` objects containing the raw comments,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func getNotificationPostComments(forNotifications notifications: [Notification], withLikes likes: Bool, completion: @escaping(Result<[Comment], FirestoreError>) -> Void) {
        
        var comments = [Comment]()
        let group = DispatchGroup()
        
        for notification in notifications {
            group.enter()
            guard let contentId = notification.contentId, let path = notification.path else {
                group.leave()
                continue
            }
            
            var query = COLLECTION_POSTS.document(contentId)
            
            for id in path {
                query = query.collection("comments").document(id)
            }
            
            query.getDocument { snapshot, error in
                
                if let _ = error {
                    group.leave()
                    return
                    
                } else {
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        group.leave()
                        return
                    }
                    
                    if likes {
                        var commentLikes = 0
                        
                        let date = DataService.shared.getLastDate(forContentId: contentId, forPath: path, withKind: .likePostReply)
                        fetchLikesForPostComment(postId: contentId, path: path, startingAt: date) { result in
                            switch result {
                            case .success(let likes):
                                commentLikes = likes
                            case .failure(_):
                                commentLikes = 0
                            }
                            
                            var comment = Comment(dictionary: data)
                            comment.likes = commentLikes
                            comments.append(comment)
                            group.leave()
                        }
                    } else {
                        let comment = Comment(dictionary: data)
                        comments.append(comment)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(comments))
        }
    }
    
    /// Fetches the raw comments for the given notifications related to cases.
    ///
    /// - Parameters:
    ///   - notifications: An array of `Notification` objects for which raw comments are to be fetched.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[Comment], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `Comment` objects containing the raw comments,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func getNotificationCaseComments(forNotifications notifications: [Notification], withLikes likes: Bool, completion: @escaping(Result<[Comment], FirestoreError>) -> Void) {

        var comments = [Comment]()
        let group = DispatchGroup()
        
        for notification in notifications {
            group.enter()

            guard let contentId = notification.contentId, let path = notification.path else {
                group.leave()
                continue
            }
            
            var query = COLLECTION_CASES.document(contentId)
            
            for id in path {
                query = query.collection("comments").document(id)
            }
            
            query.getDocument { snapshot, error in
                if let _ = error {
                    group.leave()
                } else {
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        group.leave()
                        return
                    }
                    
                    if likes {
                        
                        var commentLikes = 0
                        
                        let date = DataService.shared.getLastDate(forContentId: contentId, forPath: path, withKind: .likeCaseReply)
                        
                        fetchLikesForCaseComment(caseId: contentId, path: path, startingAt: date) { result in
                            switch result {
                            case .success(let likes):
                                commentLikes = likes
                            case .failure(_):
                                commentLikes = 0
                            }
                            
                            var comment = Comment(dictionary: data)
                            comment.likes = commentLikes
                            comments.append(comment)
                            group.leave()
                        }
                    } else {
                        let comment = Comment(dictionary: data)
                        comments.append(comment)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(comments))
        }
    }
}

//MARK: - Miscellaneous

extension CommentService {
    
    /// Fetches the values for an array of comments for a specific post.
    ///
    /// - Parameters:
    ///   - post: The post to which the comments belong.
    ///   - comments: An array of comments to fetch values for.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes an array of `Comment` objects with updated values.
    static func getPostCommentsValuesFor(forPost post: Post, forPath path: [String], forComments comments: [Comment], completion: @escaping([Comment]) -> Void) {
        var commentsWithValues = [Comment]()
        comments.forEach { comment in
            getPostCommentValuesFor(forPost: post, forPath: path, forComment: comment) { fetchedComment in
                commentsWithValues.append(fetchedComment)
                if commentsWithValues.count == comments.count {
                    completion(commentsWithValues)
                }
            }
        }
    }
    
    /// Retrieves additional values for a specific comment in a post.
    ///
    /// - Parameters:
    ///   - post: The post that the comment belongs to.
    ///   - comment: The comment for which additional values will be retrieved.
    ///   - completion: A closure to be called when the retrieval is completed.
    ///                 It takes a single parameter of type `Comment`.
    static func getPostCommentValuesFor(forPost post: Post, forPath path: [String], forComment comment: Comment, completion: @escaping(Comment) -> Void) {

        var auxComment = comment
        let group = DispatchGroup()
        
        group.enter()
        checkIfUserLikedComment(forPost: post, forCommentId: comment.id) { result in
            switch result {
            case .success(let didLike):
                auxComment.didLike = didLike
            case .failure(_):
                auxComment.didLike = false
            }

            group.leave()
        }
        
        group.enter()
        fetchCommentLikes(forPost: post, forPath: path, forCommentId: comment.id) { result in
            switch result {
            case .success(let likes):
                auxComment.likes = likes
            case .failure(_):
                auxComment.likes = 0
            }

            group.leave()
        }
        
        group.enter()
        fetchNumberOfComments(forPost: post, forPath: path, forCommentId: comment.id) { result in
            switch result {
            case .success(let comments):
                auxComment.numberOfComments = comments
            case .failure(_):
                auxComment.numberOfComments = 0
            }

            group.leave()
        }
        
        group.enter()
        checkIfAuthorDidReplyComment(forPost: post, forPath: path, forCommentId: comment.id) { result in
            switch result {
            case .success(let hasCommentsFromAuthor):
                auxComment.hasCommentFromAuthor = hasCommentsFromAuthor
            case .failure(_):
                auxComment.hasCommentFromAuthor = false
            }

            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(auxComment)
        }
    }
    
    /// Fetches the number of likes for a comment within a post.
    ///
    /// - Parameters:
    ///   - post: The Post object to which the comment belongs.
    ///   - path: The array representing the path to the comment.
    ///   - id: The identifier of the comment.
    ///   - completion: A completion block that is called with the result of the query.
    static func fetchCommentLikes(forPost post: Post, forPath path: [String], forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {

        var ref = COLLECTION_POSTS.document(post.postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let likesRef = ref.document(id).collection("likes").count
        
        likesRef.getAggregation(source: .server) { snapshot, error in
             if let _ = error {
                 completion(.failure(.unknown))
             } else {
                 if let likes = snapshot?.count {
                     completion(.success(likes.intValue))
                 } else {
                     completion(.success(0))
                 }
             }
         }
     }
     
    /// Fetches the number of likes for a specific comment in a post.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the comment to fetch likes for.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result` enum with either an `Int` representing the number of likes on success
    ///                 or a `FirestoreError` on failure.
    static func fetchNumberOfComments(forPost post: Post, forPath path: [String], forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
         
        
        var ref = COLLECTION_POSTS.document(post.postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let commentsRef = ref.document(id).collection("comments")
        
        let query = commentsRef.whereField("visible", isGreaterThanOrEqualTo: 0).whereField("visible", isLessThanOrEqualTo: 1).count
         
         query.getAggregation(source: .server) { snapshot, error in
             if let _ = error {
                 completion(.failure(.unknown))
             } else {
                 if let likes = snapshot?.count {
                     completion(.success(likes.intValue))
                 } else {
                     completion(.success(0))
                 }
             }
         }
     }
    
    /// Checks if the author of a post has replied to a specific comment.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the comment to check for replies from the post author.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result` enum with either a `Bool` indicating if the author has replied (true) or not (false) on success
    ///                 or a `FirestoreError` on failure.
    static func checkIfAuthorDidReplyComment(forPost post: Post, forPath path: [String], forCommentId id: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        
        var ref = COLLECTION_POSTS.document(post.postId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let commentsRef = ref.document(id).collection("comments").whereField("uid", isEqualTo: post.uid).limit(to: 1)
        
        commentsRef.getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.success(false))
                    return
                }
                
                completion(.success(true))
            }
        }
    }
    
    /// Checks if the current user has liked a specific comment on a post.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the comment to check if the user has liked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result` enum with either a `Bool` indicating if the user has liked the comment (true) or not (false) on success
    ///                 or a `FirestoreError` on failure.
     static func checkIfUserLikedComment(forPost post: Post, forCommentId id: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
         guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
         
         COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(id).getDocument { snapshot, error in
             if let _ = error {
                 completion(.failure(.unknown))
             } else {
                 guard let snapshot = snapshot, snapshot.exists else {
                     completion(.success(false))
                     return
                 }
                 
                 completion(.success(true))
             }
         }
     }
    
    /// Get the values for multiple case comments, such as the number of likes, number of comments, and more.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case containing the comments.
    ///   - comments: The comments for which to fetch the values.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes an array of type `Comment`.
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forPath path: [String], forComments comments: [Comment], completion: @escaping([Comment]) -> Void) {
        var commentsWithValues = [Comment]()
        comments.forEach { comment in
            getCaseCommentValuesFor(forCase: clinicalCase, forPath: path, forComment: comment) { fetchedComment in
                commentsWithValues.append(fetchedComment)
                if commentsWithValues.count == comments.count {
                    completion(commentsWithValues)
                }
            }
        }
    }
    
    /// Get the values for a case comment, such as the number of likes, number of comments, and more.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case containing the comment.
    ///   - comment: The comment for which to fetch the values.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a single parameter of type `Comment`.
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forPath path: [String], forComment comment: Comment, completion: @escaping(Comment) -> Void) {
        
        var auxComment = comment
        let group = DispatchGroup()
        
        group.enter()
        checkIfUserLikedCaseComment(forCase: clinicalCase, forCommentId: comment.id) { result in
            switch result {
                
            case .success(let didLike):
                auxComment.didLike = didLike
            case .failure(_):
                auxComment.didLike = false
            }
            
            group.leave()
        }
        
        group.enter()
        
        fetchCommentLikes(forCase: clinicalCase, forPath: path, forCommentId: comment.id) { result in
            switch result {
                
            case .success(let likes):
                auxComment.likes = likes
            case .failure(_):
                auxComment.likes = 0
            }
            
            group.leave()
        }
        
        group.enter()
        fetchNumberOfComments(forCase: clinicalCase, forPath: path, forCommentId: comment.id) { result in
            switch result {
                
            case .success(let numberOfComments):
                auxComment.numberOfComments = numberOfComments
            case .failure(_):
                auxComment.numberOfComments = 0
            }
            
            group.leave()
        }
        
        group.enter()
        checkIfAuthorDidReplyComment(forCase: clinicalCase, forPath: path, forCommentId: comment.id) { result in
            switch result {
                
            case .success(let hasCommentFromAuthor):

                auxComment.hasCommentFromAuthor = hasCommentFromAuthor
            case .failure(_):
                auxComment.hasCommentFromAuthor = false
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            auxComment.edit(clinicalCase.uid == comment.uid)
            completion(auxComment)
        }
    }
    
    /// Fetches the number of likes for a comment within a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The Case object to which the comment belongs.
    ///   - path: The array representing the path to the comment.
    ///   - id: The identifier of the comment.
    ///   - completion: A completion block that is called with the result of the query.
    static func fetchCommentLikes(forCase clinicalCase: Case, forPath path: [String], forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {

        var ref = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let likesRef = ref.document(id).collection("likes").count
        
        likesRef.getAggregation(source: .server) { snapshot, error in
             if let _ = error {
                 completion(.failure(.unknown))
             } else {
                 if let likes = snapshot?.count {
                     completion(.success(likes.intValue))
                 } else {
                     completion(.success(0))
                 }
             }
         }
     }
    
    /// Checks if the user liked a specific case comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case to check for the user's like on the comment.
    ///   - id: The unique identifier of the comment to check for the user's like.
    ///   - completion: A closure to be called when the checking is completed.
    ///                 It takes a single parameter of type `Result<Bool, FirestoreError>`.
    ///                 The `Result` will contain a `Bool` indicating whether the user liked the specified comment or not.
    static func checkIfUserLikedCaseComment(forCase clinicalCase: Case, forCommentId id: String, completion: @escaping(Result<Bool,FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(id).getDocument { snapshot, error in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(.success(false))
                    return
                }
                
                completion(.success(true))
            }
        }
    }

    
    /// Fetches the count of likes for a specific post, optionally starting from a certain date.
    ///
    /// - Parameters:
    ///   - postId: The unique identifier of the post.
    ///   - date: An optional `Date` representing the starting date to fetch likes from.
    ///   - completion: A closure that receives a result containing the like count or an error.
    static func fetchLikesForPostComment(postId: String, path: [String], startingAt date: Date?, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        if let date {
            let timestamp = Timestamp(date: date)
            var likesRef = COLLECTION_POSTS.document(postId)
            
            for id in path {
                likesRef = likesRef.collection("comments").document(id)
            }
            
            let query = likesRef.collection("likes").whereField("timestamp", isGreaterThan: timestamp).count

            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    if let likes = snapshot?.count {
                        completion(.success(likes.intValue))
                    } else {
                        completion(.success(0))
                    }
                }
            }
        } else {
            var likesRef = COLLECTION_POSTS.document(postId)
            
            for id in path {
                likesRef = likesRef.collection("comments").document(id)
            }
            
            let query = likesRef.collection("likes").count

            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    if let likes = snapshot?.count {
                        completion(.success(likes.intValue))
                    } else {
                        completion(.success(0))
                    }
                }
            }
        }
    }
    
    /// Fetches the count of likes for a specific post, optionally starting from a certain date.
    ///
    /// - Parameters:
    ///   - postId: The unique identifier of the post.
    ///   - date: An optional `Date` representing the starting date to fetch likes from.
    ///   - completion: A closure that receives a result containing the like count or an error.
    static func fetchLikesForCaseComment(caseId: String, path: [String], startingAt date: Date?, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        if let date {
            let timestamp = Timestamp(date: date)
            var likesRef = COLLECTION_CASES.document(caseId)
            
            for id in path {
                likesRef = likesRef.collection("comments").document(id)
            }
            
            let query = likesRef.collection("likes").whereField("timestamp", isGreaterThan: timestamp).count

            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    if let likes = snapshot?.count {
                        completion(.success(likes.intValue))
                    } else {
                        completion(.success(0))
                    }
                }
            }
        } else {
            var likesRef = COLLECTION_CASES.document(caseId)
            
            for id in path {
                likesRef = likesRef.collection("comments").document(id)
            }
            
            let query = likesRef.collection("likes").count

            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
                    if let likes = snapshot?.count {
                        completion(.success(likes.intValue))
                    } else {
                        completion(.success(0))
                    }
                }
            }
        }
    }

    /// Fetches the number of visible comments for a specific case comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case to fetch the number of comments for.
    ///   - id: The unique identifier of the comment to fetch the number of comments for.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a single parameter of type `Result<Int, FirestoreError>`.
    ///                 The `Result` will contain an `Int` indicating the number of visible comments for the specified comment.
    static func fetchNumberOfComments(forCase clinicalCase: Case, forPath path: [String], forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
         
        var ref = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let commentsRef = ref.document(id).collection("comments")
        
        let query = commentsRef.whereField("visible", isGreaterThanOrEqualTo: 0).whereField("visible", isLessThanOrEqualTo: 1).count
         
         query.getAggregation(source: .server) { snapshot, error in
             if let _ = error {
                 completion(.failure(.unknown))
             } else {
                 if let likes = snapshot?.count {
                     completion(.success(likes.intValue))
                 } else {
                     completion(.success(0))
                 }
             }
         }
     }
    
    /// Checks if the author of a clinical case has replied to a specific comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case to check.
    ///   - commentUid: The unique identifier of the comment to check if the author has replied to.
    ///   - completion: A closure to be called when the check is completed.
    ///                 It takes a single parameter of type `Result<Bool, FirestoreError>`.
    ///                 The `Result` will contain a `Bool` indicating whether the author has replied to the comment or not.
    static func checkIfAuthorDidReplyComment(forCase clinicalCase: Case, forPath path: [String], forCommentId id: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        
        var ref = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
        
        for id in path {
            ref = ref.document(id).collection("comments")
        }
        
        let commentsRef = ref.document(id).collection("comments").whereField("uid", isEqualTo: clinicalCase.uid).limit(to: 1)
        
        commentsRef.getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.success(false))
                    return
                }
                completion(.success(true))
            }
        }
    }
}


