//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct CommentService {
    
}

//MARK: - Delete Operations

extension CommentService {
    
    //MARK: - Delete Case Comment
    
    static func deleteComment(forCase clinicalCase: Case, forCommentId commentId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        /// Deletes a comment from a clinical case.
        ///
        /// - Parameters:
        ///   - clinicalCase: The clinical case from which the comment will be deleted.
        ///   - commentId: The ID of the comment to be deleted.
        ///   - completion: A closure to be called when the operation is completed.
        ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).updateData(["visible": Visible.deleted.rawValue]) { error in
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
    
    //MARK: - Delete Case Reply
    
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
    
    //MARK: - Delete Post Comment
    
    /// Deletes a comment from a post.
    ///
    /// - Parameters:
    ///   - post: The post from which the comment will be deleted.
    ///   - id: The ID of the comment to be deleted.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the deletion is successful, or an error if it fails.
    static func deleteComment(forPost post: Post, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        COLLECTION_POSTS.document(post.postId).collection("comments").document(id).updateData(["visible": Visible.deleted.rawValue]) { error in
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
                DatabaseManager.shared.deleteRecentComment(forCommentId: id) { _ in
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - Delete Post Reply
    
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
    
    //MARK: - Add Case Comment
    
    /// Adds a new comment to a clinical case.
    ///
    /// - Parameters:
    ///   - comment: The content of the comment to be added.
    ///   - clinicalCase: The clinical case to which the comment is added.
    ///   - user: The user who is adding the comment.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<Comment, FirestoreError>` parameter, which contains the added comment if successful, or an error if it fails.
    static func addComment(_ comment: String, for clinicalCase: Case, from user: User, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document()
        
        let anonymous = user.uid == clinicalCase.uid && clinicalCase.privacy == .anonymous
        
        var data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
        
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
                comment.isAuthor = user.uid == clinicalCase.uid
                completion(.success(comment))
            }
        }
    }

    //MARK: - Add Post Comment
    
    /// Adds a new comment to a post.
    ///
    /// - Parameters:
    ///   - comment: The content of the comment to be added.
    ///   - post: The post to which the comment is added.
    ///   - user: The user who is adding the comment.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<Comment, FirestoreError>` parameter, which contains the added comment if successful, or an error if it fails.
    static func addComment(_ comment: String, for post: Post, from user: User, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document()
        
        let data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "visible": Visible.regular.rawValue,
                                   "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
        
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
                comment.edit(user.uid == post.uid)
                completion(.success(comment))
            }
        }
    }
    
    //MARK: - Case Comment Like
    
    /// Likes a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case in which the comment is located.
    ///   - id: The ID of the comment to be liked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the like is successful, or an error if it fails.
    static func likeComment(forCase clinicalCase: Case, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
        
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
         
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(id).setData(likeData) { error in
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
    
    /// Unlikes a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case in which the comment is located.
    ///   - id: The ID of the comment to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the unlike is successful, or an error if it fails.
    static func unlikeComment(forCase clinicalCase: Case, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
       
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(id).delete() { error in
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
    
    //MARK: - Post Comment Like
    
    /// Likes a comment in a post.
    ///
    /// - Parameters:
    ///   - post: The post in which the comment is located.
    ///   - id: The ID of the comment to be liked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the like is successful, or an error if it fails.
    static func likeComment(forPost post: Post, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
       
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
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(id).setData(likeData) { error in
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
    
    static func likePostComment(forId postId: String, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
       
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
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(postId).collection("comments").document(id).collection("likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(postId).collection("comment-likes").document(id).setData(likeData) { error in
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
    
    /// Unlikes a comment in a post.
    ///
    /// - Parameters:
    ///   - post: The post in which the comment is located.
    ///   - id: The ID of the comment to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError` parameter, which is nil if the unlike is successful, or an error if it fails.
    static func unlikeComment(forPost post: Post, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {

        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(id).delete() { error in
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
    
    static func unlikePostComment(forId postId: String, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {

        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(postId).collection("comments").document(id).collection("likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(postId).collection("comment-likes").document(id).delete() { error in
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

    //MARK: - Add Case Reply
    
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
    static func addReply(_ reply: String, commentId: String, clinicalCase: Case, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
       
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document()
            
            let anonymous = uid == clinicalCase.uid && clinicalCase.privacy == .anonymous
        
            var data: [String: Any] = ["uid": uid,
                                       "comment": reply,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
            
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
                comment.edit(uid == clinicalCase.uid)
                completion(.success(comment))
            }
        }
    }
    
    //MARK: - Add Post Reply
    
    /// Add a reply to a post comment.
    ///
    /// - Parameters:
    ///   - reply: The reply text to be added.
    ///   - commentId: The ID of the parent comment for which the reply belongs.
    ///   - post: The post to which the comment belongs.
    ///   - user: The user creating the reply.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a single parameter of type `Result<Comment, FirestoreError>`.
    ///                 The result will be either `.success` with the added `Comment` object,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func addReply(_ reply: String, commentId: String, post: Post, user: User, completion: @escaping(Result<Comment, FirestoreError>) -> Void) {
       
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").document()

            let data: [String: Any] = ["uid": uid,
                                       "comment": reply,
                                       "id": commentRef.documentID,
                                       "visible": Visible.regular.rawValue,
                                       "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
        
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
                comment.edit(user.uid == post.uid)
                completion(.success(comment))
            }
        }
    }
    
    //MARK: - Case Reply Like
    
    /// Unlike a reply to a case comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The case to which the comment belongs.
    ///   - id: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the reply to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError?` object, which will be `nil` if the operation was successful.
    static func unlikeReply(forCase clinicalCase: Case, forCommentId id: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
       
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).delete() { error in
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
    
    /// Like a reply to a case comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The case to which the comment belongs.
    ///   - id: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the reply to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError?` object, which will be `nil` if the operation was successful.
    static func likeReply(forCase clinicalCase: Case, forCommentId id: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
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
        
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).setData(likeData) { error in
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
    
    
    //MARK: - Post Reply Like
    
    /// Like a reply to a post comment.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the reply to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError?` object, which will be `nil` if the operation was successful.
    static func likeReply(forPost post: Post, forCommentId id: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
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
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).setData(likeData) { error in
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
    
    /// Like a reply to a post comment.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the reply to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError?` object, which will be `nil` if the operation was successful.
    static func likePostReply(forId postId: String, forCommentId id: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
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
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(postId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(postId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).setData(likeData) { error in
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
    
    
    /// Unlike a reply to a post comment.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the reply to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError?` object, which will be `nil` if the operation was successful.
    static func unlikeReply(forPost post: Post, forCommentId id: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
       
        dispatchGroup.enter()
        COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).delete() { error in
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
    
    /// Unlike a reply to a post comment.
    ///
    /// - Parameters:
    ///   - post: The post to which the comment belongs.
    ///   - id: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the reply to be unliked.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `FirestoreError?` object, which will be `nil` if the operation was successful.
    static func unlikePostReply(forId postId: String, forCommentId id: String, forReplyId replyId: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
       
        dispatchGroup.enter()
        COLLECTION_POSTS.document(postId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(postId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).delete() { error in
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
}

// MARK: - Fetch Operations

extension CommentService {

    //MARK: - Post Comments

    /// Fetches post comments for a given post.
    ///
    /// - Parameters:
    ///   - post: The post for which to fetch the comments.
    ///   - lastSnapshot: The last snapshot from which to start the query. Pass nil to start from the beginning.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<QuerySnapshot, FirestoreError>` parameter, which contains the fetched query snapshot if successful, or an error if it fails.
    static func fetchPostComments(forPost post: Post, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        
        if lastSnapshot == nil {
            
            COLLECTION_POSTS.document(post.postId).collection("comments").order(by: "timestamp", descending: true).limit(to: 15).getDocuments { snapshot, error in
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
            
            COLLECTION_POSTS.document(post.postId).collection("comments").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, error in
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

    //MARK: - Post Replies
    
    /// Fetches replies for a specific comment in a post.
    ///
    /// - Parameters:
    ///   - post: The post for which the comment belongs.
    ///   - commentId: The ID of the comment for which replies will be fetched.
    ///   - lastSnapshot: The last snapshot of the previous batch of replies. Pass `nil` to fetch the first batch.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the fetched `QuerySnapshot`,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchRepliesForPostComment(forPost post: Post, forCommentId commentId: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            let query = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).limit(to: 15)
            
            query.getDocuments { snapshot, error in
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
            
            let query = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
            
            query.getDocuments { snapshot, error in
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
    
    //MARK: - Case Comments
    
    /// Fetches case comments for a given clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case for which to fetch the comments.
    ///   - lastSnapshot: The last snapshot from which to start the query. Pass nil to start from the beginning.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes a `Result<QuerySnapshot?, FirestoreError>` parameter, which contains the fetched query snapshot if successful, or an error if it fails.
    static func fetchCaseComments(forCase clinicalCase: Case, lastSnapshot: QueryDocumentSnapshot?,  completion: @escaping(Result<QuerySnapshot?, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: true).limit(to: 15)
            query.getDocuments { snapshot, error in

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
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        } else {
            
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
            
            query.getDocuments { snapshot, error in
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
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    
    
    //MARK: - Case Replies
    
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
    static func fetchRepliesForCaseComment(forClinicalCase clinicalCase: Case, forCommentId commentId: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).limit(to: 15)
            
            query.getDocuments { snapshot, error in
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
            
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
            
            query.getDocuments { snapshot, error in
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
    
    //MARK: - Notification Comments
    
    /// Fetches the raw comments for the given notifications.
    ///
    /// - Parameters:
    ///   - notifications: An array of `Notification` objects for which raw comments are to be fetched.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[Comment], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `Comment` objects containing the raw comments,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func getRawPostComments(forNotifications notifications: [Notification], completion: @escaping(Result<[Comment], FirestoreError>) -> Void) {
        var comments = [Comment]()
        let group = DispatchGroup()
        
        for notification in notifications {
            group.enter()
            let query = COLLECTION_POSTS.document(notification.contentId).collection("comments").document(notification.commentId)
            query.getDocument { snapshot, error in
               
                if let _ = error {
                    completion(.failure(.unknown))
                    return

                } else {
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        completion(.failure(.notFound))
                        return
                    }
                    
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                    group.leave()
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
    static func getRawCaseComments(forNotifications notifications: [Notification], completion: @escaping(Result<[Comment], FirestoreError>) -> Void) {
        var comments = [Comment]()
        let group = DispatchGroup()
        
        for notification in notifications {
            group.enter()
            let query = COLLECTION_CASES.document(notification.contentId).collection("comments").document(notification.commentId)
            query.getDocument { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                    return

                } else {
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        completion(.failure(.notFound))
                        return
                    }
                    
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                    group.leave()
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
    
    //MARK: - Post Comments

    /// Fetches the values for an array of comments for a specific post.
    ///
    /// - Parameters:
    ///   - post: The post to which the comments belong.
    ///   - comments: An array of comments to fetch values for.
    ///   - completion: A closure to be called when the operation is completed.
    ///                 It takes an array of `Comment` objects with updated values.
    static func getPostCommentsValuesFor(forPost post: Post, forComments comments: [Comment], completion: @escaping([Comment]) -> Void) {
        var commentsWithValues = [Comment]()
        comments.forEach { comment in
            getPostCommentValuesFor(forPost: post, forComment: comment) { fetchedComment in
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
    static func getPostCommentValuesFor(forPost post: Post, forComment comment: Comment, completion: @escaping(Comment) -> Void) {

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
        fetchCommentLikes(forPost: post, forCommentId: comment.id) { result in
            switch result {
            case .success(let likes):
                auxComment.likes = likes
            case .failure(_):
                auxComment.likes = 0
            }

            group.leave()
        }
        
        group.enter()
        fetchNumberOfComments(forPost: post, forCommentId: comment.id) { result in
            switch result {
            case .success(let comments):
                auxComment.numberOfComments = comments
            case .failure(_):
                auxComment.numberOfComments = 0
            }

            group.leave()
        }
        
        group.enter()
        checkIfAuthorDidReplyComment(forPost: post, forCommentId: comment.id) { result in
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
    
     static func fetchCommentLikes(forPost post: Post, forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
         
         let likesRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("likes").count
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
     static func fetchNumberOfComments(forPost post: Post, forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
         
         let commentsRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("comments")
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
     static func checkIfAuthorDidReplyComment(forPost post: Post, forCommentId id: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
         let commentsRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(id).collection("comments").whereField("uid", isEqualTo: post.uid).limit(to: 1)
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
    
    //MARK: - Post Replies
    
    /// Checks if the user has liked a specific reply to a comment in a post.
    ///
    /// - Parameters:
    ///   - post: The post that the comment and reply belong to.
    ///   - commentId: The ID of the comment that the reply belongs to.
    ///   - replyId: The ID of the reply to check for the user's like.
    ///   - completion: A closure to be called when the check is completed.
    ///                 It takes a single parameter of type `Result<Bool, FirestoreError>`.
    ///                 The result will be either `.success(true)` if the user has liked the reply,
    ///                 or `.success(false)` if the user has not liked the reply,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func checkIfUserLikedCommentReply(forPost post: Post, forCommentId commentId: String, forReplyId replyId: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentId).collection("comment-likes").document(replyId).getDocument { snapshot, error in
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
    
    /// Fetch the number of likes for a post comment reply.
    ///
    /// - Parameters:
    ///   - post: The post containing the comment reply.
    ///   - commentId: The ID of the parent comment for which the reply belongs.
    ///   - replyId: The ID of the comment reply for which to fetch the likes.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a `Result<Int, FirestoreError>` object.
    static func fetchLikesForPostCommentReply(forPost post: Post, forCommentId commentId: String, forReplyId replyId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        
        let likesRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").document(replyId).collection("likes").count
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
    
    /// Get the values for a post comment reply, such as the number of likes and more.
    ///
    /// - Parameters:
    ///   - post: The post containing the comment reply.
    ///   - comment: The parent comment for which the reply belongs.
    ///   - reply: The comment reply for which to fetch the values.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a `Comment` object with updated values.
    static func getPostReplyCommentValuesFor(forPost post: Post, forComment comment: Comment, forReply reply: Comment, completion: @escaping(Comment) -> Void) {

        var auxComment = reply
        let group = DispatchGroup()
        
        group.enter()
        checkIfUserLikedCommentReply(forPost: post, forCommentId: comment.id, forReplyId: reply.id) { result in
            switch result {
            case .success(let didLike):
                auxComment.didLike = didLike
            case .failure(_):
                auxComment.didLike = false
            }

            group.leave()
        }
        
        group.enter()
        fetchLikesForPostCommentReply(forPost: post, forCommentId: comment.id, forReplyId: reply.id) { result in
            switch result {
            case .success(let likes):
                auxComment.likes = likes
            case .failure(_):
                auxComment.likes = 0
            }

            group.leave()
        }
        
        group.notify(queue: .main) {
            auxComment.edit(post.uid == reply.uid)
            completion(auxComment)
        }
    }

    /// Get the values for multiple post comment replies, such as the number of likes and more.
    ///
    /// - Parameters:
    ///   - post: The post containing the comment replies.
    ///   - comment: The parent comment for which the replies belong.
    ///   - replies: The comment replies for which to fetch the values.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes an array of type `Comment`.
    static func getPostRepliesCommmentsValuesFor(forPost post: Post, forComment comment: Comment, forReplies replies: [Comment], completion: @escaping([Comment]) -> Void) {
        
        var repliesWithValues = [Comment]()
        
        replies.forEach { reply in
            getPostReplyCommentValuesFor(forPost: post, forComment: comment, forReply: reply) { fetchedReplies in
                repliesWithValues.append(fetchedReplies)
                if repliesWithValues.count == replies.count {
                    completion(repliesWithValues)
                }
            }
        }
    }
    
    
    //MARK: - Case Comments
    
    /// Get the values for multiple case comments, such as the number of likes, number of comments, and more.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case containing the comments.
    ///   - comments: The comments for which to fetch the values.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes an array of type `Comment`.
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forComments comments: [Comment], completion: @escaping([Comment]) -> Void) {
        var commentsWithValues = [Comment]()
        comments.forEach { comment in
            getCaseCommentValuesFor(forCase: clinicalCase, forComment: comment) { fetchedComment in
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
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forComment comment: Comment, completion: @escaping(Comment) -> Void) {
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
        fetchLikesForCaseComment(forCase: clinicalCase, forCommentId: comment.id) { result in
            switch result {
                
            case .success(let likes):
                auxComment.likes = likes
            case .failure(_):
                auxComment.likes = 0
            }
            
            group.leave()
        }
        
        group.enter()
        fetchNumberOfCommentsForCaseComment(forCase: clinicalCase, forCommentId: comment.id) { result in
            switch result {
                
            case .success(let numberOfComments):
                auxComment.numberOfComments = numberOfComments
            case .failure(_):
                auxComment.numberOfComments = 0
            }
            
            group.leave()
        }
        
        group.enter()
        checkIfAuthorDidReplyCaseComment(forCase: clinicalCase, forCommentUid: comment.id) { result in
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
    
    /// Fetches the number of likes for a specific case comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case to fetch the number of likes for.
    ///   - id: The unique identifier of the comment to fetch the number of likes for.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a single parameter of type `Result<Int, FirestoreError>`.
    ///                 The `Result` will contain an `Int` indicating the number of likes for the specified comment.
    static func fetchLikesForCaseComment(forCase clinicalCase: Case, forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        let likesRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("likes").count
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
    
    //MARK: - Case Replies
    
    /// Fetches the number of visible comments for a specific case comment.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case to fetch the number of comments for.
    ///   - id: The unique identifier of the comment to fetch the number of comments for.
    ///   - completion: A closure to be called when the fetching is completed.
    ///                 It takes a single parameter of type `Result<Int, FirestoreError>`.
    ///                 The `Result` will contain an `Int` indicating the number of visible comments for the specified comment.
    static func fetchNumberOfCommentsForCaseComment(forCase clinicalCase: Case, forCommentId id: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        
        let commentsRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("comments")
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
    static func checkIfAuthorDidReplyCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        let commentsRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: clinicalCase.uid).limit(to: 1)
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

    /// Fetches the like status and like count for multiple replies to a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case that the comment and replies belong to.
    ///   - comment: The original comment that the replies belong to.
    ///   - replies: The array of replies for which to fetch the like status and count.
    ///   - completion: A closure to be called when the data fetching is completed.
    ///                 It takes a single parameter of type `[Comment]`.
    ///                 The `[Comment]` parameter will contain the replies with their `didLike` and `likes` properties updated
    ///                 based on the like status and count fetched from the Firestore database.
    static func getCaseRepliesCommmentsValuesFor(forCase clinicalCase: Case, forComment comment: Comment, forReplies replies: [Comment], completion: @escaping([Comment]) -> Void) {
        var repliesWithValues = [Comment]()
        
        replies.forEach { reply in
            getCaseReplyCommentValuesFor(forCase: clinicalCase, forComment: comment, forReply: reply) { fetchedReplies in
                repliesWithValues.append(fetchedReplies)
                if repliesWithValues.count == replies.count {
                    completion(repliesWithValues)
                }
            }
        }
    }
    
    /// Fetches the like status and like count for a reply to a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case that the comment and reply belong to.
    ///   - comment: The original comment that the reply belongs to.
    ///   - reply: The reply for which to fetch the like status and count.
    ///   - completion: A closure to be called when the data fetching is completed.
    ///                 It takes a single parameter of type `Comment`.
    ///                 The `Comment` parameter will have its `didLike` and `likes` properties updated
    ///                 based on the like status and count fetched from the Firestore database.
    static func getCaseReplyCommentValuesFor(forCase clinicalCase: Case, forComment comment: Comment, forReply reply: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = reply
        let group = DispatchGroup()
        
        group.enter()
        checkIfUserLikedCaseCommentReply(forCase: clinicalCase, forCommentId: comment.id, forReplyId: reply.id) { result in
            switch result {
            case .success(let didLike):
                auxComment.didLike = didLike
            case .failure(_):
                auxComment.didLike = false
            }
            
            group.leave()
        }
        
        group.enter()
        fetchLikesForCaseCommentReply(forCase: clinicalCase, forCommentId: comment.id, forReplyId: reply.id) { result in
            switch result {
            case .success(let likes):
                auxComment.likes = likes
            case .failure(_):
                auxComment.likes = 0
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            auxComment.edit(clinicalCase.uid == reply.uid)
            completion(auxComment)
        }
    }

    /// Checks if the current user has liked a specific reply to a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case that the comment and reply belong to.
    ///   - id: The ID of the original comment that the reply belongs to.
    ///   - replyId: The ID of the reply to check if the user has liked.
    ///   - completion: A closure to be called when the check is completed.
    ///                 It takes a single parameter of type `Result<Bool, FirestoreError>`.
    ///                 The result will be either `.success(true)` if the user has liked the reply,
    ///                 or `.success(false)` if the user has not liked the reply,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func checkIfUserLikedCaseCommentReply(forCase clinicalCase: Case, forCommentId id: String, forReplyId replyId: String, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(id).collection("comment-likes").document(replyId).getDocument { snapshot, error in
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
    
    /// Fetches the number of likes for a specific reply to a comment in a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case that the comment and reply belong to.
    ///   - id: The ID of the original comment that the reply belongs to.
    ///   - replyId: The ID of the reply to fetch the number of likes for.
    ///   - completion: A closure to be called when the retrieval is completed.
    ///                 It takes a single parameter of type `Result<Int, FirestoreError>` which represents the number of likes.
    static func fetchLikesForCaseCommentReply(forCase clinicalCase: Case, forCommentId id: String, forReplyId replyId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        let likesRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(id).collection("comments").document(replyId).collection("likes").count
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
}


