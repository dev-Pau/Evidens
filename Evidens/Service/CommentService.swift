//
//  CommentService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/11/21.
//

import Firebase

struct CommentService {
    
    static func addComment(_ comment: String, for clinicalCase: Case, from user: User, completion: @escaping(Result<Comment, Error>) -> Void) {
        
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
                completion(.failure(error))
            } else {
                var comment = Comment(dictionary: data)
                comment.isAuthor = user.uid == clinicalCase.uid
                completion(.success(comment))
            }
        }
    }
    
    static func addComment(_ comment: String, for post: Post, from user: User, completion: @escaping(Result<Comment, Error>) -> Void) {
        let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document()
        
        var data: [String: Any] = ["uid": user.uid as Any,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "visible": Visible.regular.rawValue,
                                   "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
        
        commentRef.setData(data) { error in
            if let error {
                completion(.failure(error))
            } else {
                var comment = Comment(dictionary: data)
                comment.isAuthor = user.uid == post.uid
                completion(.success(comment))
            }
        }
    }
    
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
    
    static func fetchComments(forPost post: Post, completion: @escaping([Comment]) -> Void) {
        let query = COLLECTION_POSTS.document(post.postId).collection("comments")
            .order(by: "timestamp", descending: false)
        
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                return
            }
        }
    }
    
    static func fetchRepliesForCaseComment(forClinicalCase clinicalCase: Case, forCommentId commentId: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).limit(to: 15)
            
            query.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                }
                completion(snapshot)
                
            }
        } else {
            
            let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
            
            query.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(snapshot!)
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(snapshot)
                    return
                }
                
                completion(snapshot)
                
            }
        }
    }
    
    static func fetchRepliesForPostComment(forPost post: Post, forCommentId commentId: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
         
                let query = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).limit(to: 15)
                
                query.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        print("first")
                        completion(snapshot!)
                        return
                    }
                    
                    guard snapshot.documents.last != nil else {
                        print("second")
                        completion(snapshot)
                        return
                    }
                    print("third")
                    completion(snapshot)

                }
            
        } else {
           
                let query = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
                
                query.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(snapshot!)
                        return
                    }
                    
                    guard snapshot.documents.last != nil else {
                        completion(snapshot)
                        return
                    }
                    
                    completion(snapshot)

                }
            
        }
    }
    
    
    
    static func fetchCaseComments(forCase clinicalCase: Case, completion: @escaping([Comment]) -> Void) {
        
        let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments")
            .order(by: "timestamp", descending: false)
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let comments = documents.map({ Comment(dictionary: $0.data())})
            completion(comments)
        }
    }
    
    static func fetchNotificationPostComments(withNotifications notifications: [Notification], completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        
        guard !notifications.isEmpty else {
            completion(comments)
            return
        }
        
        notifications.forEach { notification in
            let query = COLLECTION_POSTS.document(notification.contentId).collection("comments").document(notification.commentId)
            query.getDocument { snapshot, error in
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(comments)
                    return
                }
                
                comments.append(Comment(dictionary: data))
                if comments.count == notifications.count {
                    completion(comments)
                }
            }
        }
    }
    
    
    
    static func fetchNotificationCaseComments(withNotifications notifications: [Notification], completion: @escaping([Comment]) -> Void) {
        var comments = [Comment]()
        
        guard !notifications.isEmpty else {
            completion(comments)
            return
        }
        
        notifications.forEach { notification in
            let query = COLLECTION_CASES.document(notification.contentId).collection("comments").document(notification.commentId)
            query.getDocument { snapshot, error in
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    completion(comments)
                    return
                }
                
                comments.append(Comment(dictionary: data))
                if comments.count == notifications.count {
                    print(comments)
                    completion(comments)
                }
            }
        }
    }
    
    static func fetchNumberOfCommentsForPost(post: Post, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count

            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").count
            commentRef.getAggregation(source: .server) { snaphsot, _ in
                //guard let snaphsot = snaphsot else { return }
                if let comments = snaphsot?.count {
                    completion(comments.intValue)
                }
            
        }
    }
    
    
    static func fetchNumberOfCommentsForCase(clinicalCase: Case, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").count
        commentRef.getAggregation(source: .server) { snaphsot, _ in
            //guard let snaphsot = snaphsot else { return }
            if let comments = snaphsot?.count {
                completion(comments.intValue)
            }
        }
    }
    
    static func deletePostComment(forPost post: Post, forCommentId id: String, completion: @escaping(FirestoreError?) -> Void) {
        
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
                completion(nil)
            }
        }
    }
    
    static func deletePostReply(forPost post: Post, forCommentUid commentId: String, forReplyId replyId: String, completion: @escaping(Error?) -> Void) {
        COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").document(replyId).updateData(["visible": Visible.deleted.rawValue]) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    static func deleteCaseComment(forCase clinicalCase: Case, forCommentUid commentId: String, completion: @escaping(Error?) -> Void) {
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).updateData(["visible": Visible.deleted.rawValue]) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    
    static func deleteCaseReply(forCase clinicalCase: Case, forCommentUid commentId: String, forReplyId replyId: String, completion: @escaping(Error?) -> Void) {
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document(replyId).updateData(["visible": Visible.deleted.rawValue]) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
        /*
        COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).delete { error in
            if let _ = error {
                print("Error deleting document")
                completion(false)
                return
            }
            print("Comment deleted from firestore")
            //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments - 1])
            completion(true)
        }
         */
    }
    
    static func likeCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").document(uid)
        commentRef.setData(likeData) { _ in
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).setData(likeData, completion: completion)
        }
    }
    
    static func unlikeCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").document(uid)
        commentRef.delete { _ in
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).delete(completion: completion)
        }
    }
    
    
    static func likePostComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]

            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).setData(likeData, completion: completion)
            }
        
    }

    
    static func unlikePostComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
       
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).delete(completion: completion)
            
        }
    }
    
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
    
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forComment comment: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = comment
        checkIfUserLikedCaseComment(forCase: clinicalCase, forCommentUid: comment.id) { like in
            fetchLikesForCaseComment(forCase: clinicalCase, forCommentUid: comment.id) { likes in
                fetchNumberOfCommentsForCaseComment(forCase: clinicalCase, forCommentUid: comment.id) { comments in
                    checkIfAuthorDidReplyCaseComment(forCase: clinicalCase, forCommentUid: comment.id) { comment in
                        auxComment.didLike = like
                        auxComment.likes = likes
                        auxComment.numberOfComments = comments
                        auxComment.hasCommentFromAuthor = comment
                        completion(auxComment)
                    }
                }
            }
        }
    }
    
    static func checkIfUserLikedCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func fetchLikesForCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {
            let likesRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
    }
    
    static func fetchNumberOfCommentsForCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {
        
        let commentsRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments")
        let query = commentsRef.whereField("visible", isGreaterThanOrEqualTo: 0).whereField("visible", isLessThanOrEqualTo: 1).count
        
        query.getAggregation(source: .server) { snapshot, _ in
            if let comments = snapshot?.count {
                print(comments.intValue)
                completion(comments.intValue)
            }
        }
    }
    
    static func checkIfAuthorDidReplyCaseComment(forCase clinicalCase: Case, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        let commentsRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: clinicalCase.uid).limit(to: 1)
        commentsRef.getDocuments { snapshot, _ in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    //MARK: - Post
    
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
    
    static func getPostCommentValuesFor(forPost post: Post, forComment comment: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = comment
        checkIfUserLikedPostComment(forPost: post, forCommentUid: comment.id) { like in
            fetchLikesForPostComment(forPost: post, forCommentUid: comment.id) { likes in
                fetchNumberOfCommentsForPostComment(forPost: post, forCommentUid: comment.id) { comments in
                    checkIfAuthorDidReplyComment(forPost: post, forCommentUid: comment.id) { comment in
                        auxComment.didLike = like
                        auxComment.likes = likes
                        auxComment.numberOfComments = comments
                        auxComment.hasCommentFromAuthor = comment
                        completion(auxComment)
                    }
                }
            }
        }
    }

    static func fetchLikesForPostComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {

            let likesRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            
        }
    }
    
    static func fetchNumberOfCommentsForPostComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {

            let commentsRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments")
            let query = commentsRef.whereField("visible", isGreaterThanOrEqualTo: 0).whereField("visible", isLessThanOrEqualTo: 1).count
            
            query.getAggregation(source: .server) { snapshot, error in
                if let _ = error {
                    completion(0)
                    return
                } else {
                    if let comments = snapshot?.count {
                        completion(comments.intValue)
                    } else {
                        completion(0)
                    }
                

            }
        }
    }
    
    static func checkIfAuthorDidReplyComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {

            let commentsRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: post.uid).limit(to: 1)
            commentsRef.getDocuments { snapshot, _ in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    print("no comment")
                    completion(false)
                    return
                }
                print("has comment")
                completion(true)
            
        }
    }
    
    
    /*
     static func getGroupPostValuesFor(post: Post, completion: @escaping(Post) -> Void) {
         var auxPost = post
         checkIfUserLikedPost(post: post) { like in
             checkIfUserBookmarkedPost(post: post) { bookmark in
                 GroupService.fetchLikesForGroupPost(groupId: post.groupId!, postId: post.postId) { likes in
                     CommentService.fetchNumberOfCommentsForPost(post: post, type: .group) { comments in
                         auxPost.didLike = like
                         auxPost.didBookmark = bookmark
                         auxPost.numberOfComments = comments
                         auxPost.likes = likes
                         completion(auxPost)
                     }
                 }
             }
         }
     }
     */
    
    static func checkIfUserLikedPostComment(forPost post: Post, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
            
        }
    }
    
    //MARK: - Comment Reply
    
    static func checkIfUserLikedPostCommentReply(forPost post: Post, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
            
        }
    }
    
    static func fetchLikesForPostCommentReply(forPost post: Post, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Int) -> Void) {

            let likesRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            
        }
    }
    
    static func getPostReplyCommentValuesFor(forPost post: Post, forComment comment: Comment, forReply reply: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = reply
        checkIfUserLikedPostCommentReply(forPost: post, forCommentUid: comment.id, forReplyId: reply.id) { didLike in
            fetchLikesForPostCommentReply(forPost: post, forCommentUid: comment.id, forReplyId: reply.id) { likes in
                auxComment.likes = likes
                auxComment.didLike = didLike
                auxComment.isAuthor = post.uid == reply.uid ? true : false
                completion(auxComment)
            }
        }
    }

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

    static func likePostReplyComment(forPost post: Post, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
       
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
            
        }
    }
    
    static func unlikePostReplyComment(forPost post: Post, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
      
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).delete(completion: completion)
            
        }
    }
    
    
    
    
    
    
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
    
    
    
    
    static func getCaseReplyCommentValuesFor(forCase clinicalCase: Case, forComment comment: Comment, forReply reply: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = reply
        checkIfUserLikedCaseCommentReply(forCase: clinicalCase, forCommentUid: comment.id, forReplyId: reply.id) { didLike in
            fetchLikesForCaseCommentReply(forCase: clinicalCase, forCommentUid: comment.id, forReplyId: reply.id) { likes in
                auxComment.likes = likes
                auxComment.didLike = didLike
                auxComment.isAuthor = clinicalCase.uid == reply.uid ? true : false
                completion(auxComment)
            }
        }
    }
    
    static func checkIfUserLikedCaseCommentReply(forCase clinicalCase: Case, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func fetchLikesForCaseCommentReply(forCase clinicalCase: Case, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Int) -> Void) {
        let likesRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").count
        likesRef.getAggregation(source: .server) { snapshot, _ in
            if let likes = snapshot?.count {
                completion(likes.intValue)
            }
        }
    }
    
    static func addReply(_ reply: String, commentId: String, clinicalCase: Case, user: User, completion: @escaping(Result<Comment, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
       
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document()
            
            let anonymous = user.uid == clinicalCase.uid && clinicalCase.privacy == .anonymous
            
            var data: [String: Any] = ["uid": uid,
                                       "comment": reply,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
            
            if anonymous {
                data["visible"] = anonymous
            } else {
                data["visible"] = Visible.regular.rawValue
            }
            
            commentRef.setData(data) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    var comment = Comment(dictionary: data)
                    comment.isAuthor = user.uid == clinicalCase.uid
                    completion(.success(comment))
                }
            
        }
    }
    
    static func addReply(_ reply: String, commentId: String, post: Post, user: User, completion: @escaping(Result<Comment, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").document()

            var data: [String: Any] = ["uid": uid,
                                       "comment": reply,
                                       "id": commentRef.documentID,
                                       "visible": Visible.regular.rawValue,
                                       "timestamp": Timestamp(date: Date(timeIntervalSinceNow: -2))]
            
            commentRef.setData(data) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    var comment = Comment(dictionary: data)
                    comment.isAuthor = user.uid == post.uid
                    completion(.success(comment))
                }
            
        }
    }
    
    static func uploadCaseReplyComment(comment: String, commentId: String, clinicalCase: Case, user: User, completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document()
        let data: [String: Any] = ["uid": uid,
                                   "comment": comment,
                                   "id": commentRef.documentID,
                                   "timestamp": Timestamp(date: Date())]
        commentRef.setData(data) { _ in
            completion(commentRef.documentID)
        }
    }
    
    static func unlikeCaseReplyComment(forCase clinicalCase: Case, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
        commentRef.delete { _ in
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).delete(completion: completion)
        }
    }
    
    static func likeCaseReplyComment(forCase clinicalCase: Case, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
        commentRef.setData(likeData) { _ in
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
        }
    }
}
