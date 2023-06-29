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
                //COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments + 1])
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
    
    static func uploadPostReplyComment(comment: String, commentId: String, post: Post, user: User, type: Comment.CommentType, completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentId).collection("comments").document()
            let data: [String: Any] = ["uid": uid,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date())]
            commentRef.setData(data) { _ in
                completion(commentRef.documentID)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentId).collection("comments").document()
            let data: [String: Any] = ["uid": uid,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date())]
            commentRef.setData(data) { _ in
                completion(commentRef.documentID)
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
                //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
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
                //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments + 1])
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
    
    static func fetchComments(forPost post: Post, forType type: Comment.CommentType, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            switch type {
            case .regular:
                COLLECTION_POSTS.document(post.postId).collection("comments").order(by: "timestamp", descending: true).limit(to: 15).getDocuments { snapshot, _ in
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
            case .group:
                COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").order(by: "timestamp", descending: true).limit(to: 15).getDocuments { snapshot, _ in
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
        } else {
            switch type {
            case .regular:
                COLLECTION_POSTS.document(post.postId).collection("comments").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, _ in
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
            case .group:
                COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15).getDocuments { snapshot, _ in
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
    }
    
    static func fetchCaseComments(forCase clinicalCase: Case, forType type: Comment.CommentType, lastSnapshot: QueryDocumentSnapshot?,  completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            switch type {
            case .regular:
                let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: true).limit(to: 15)
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
            case .group:
                let query = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: true).limit(to: 15)
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
        } else {
            switch type {
            case .regular:
                let query = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
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
            case .group:
                let query = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
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
    }

    static func fetchComments(forPost post: Post, forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        //guard let documents = snapshot?.documents else { return }
        //let comments = documents.map({ Comment(dictionary: $0.data())})
        //completion(comments)
        
        
        switch type {
        case .regular:
            let query = COLLECTION_POSTS.document(post.postId).collection("comments")
                .order(by: "timestamp", descending: false)
            
            query.getDocuments { snapshot, error in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    return
                }

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
    
    static func fetchRepliesForCaseComment(forClinicalCase clinicalCase: Case, type: Comment.CommentType, forCommentId commentId: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            switch type {
            case .regular:
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
            case .group:
                let query = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).limit(to: 15)
                
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
        } else {
            switch type {
            case .regular:
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
            case .group:
                let query = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
                
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
    }
    
    static func fetchRepliesForPostComment(forPost post: Post, type: Comment.CommentType, forCommentId commentId: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            switch type {
            case .regular:
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
            case .group:
                //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-likes")
                let query = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).limit(to: 15)
                
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
        } else {
            switch type {
            case .regular:
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
            case .group:
                //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-likes")
                let query = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentId).collection("comments").order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
                
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
            //COLLECTION_POSTS.document(post.postId).updateData(["comments": post.numberOfComments - 1])
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
            //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["comments": clinicalCase.numberOfComments - 1])
            completion(true)
        }
    }
    
    static func likeCaseComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).setData(likeData, completion: completion)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).setData(likeData, completion: completion)
            }
        }
    }
    
    static func unlikeCaseComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).delete(completion: completion)
            }
            
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).delete(completion: completion)
            }
        }
    }
    
    
    static func likePostComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).setData(likeData, completion: completion)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).setData(likeData, completion: completion)
            }
        }
    }

    
    static func unlikePostComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).delete(completion: completion)
            }
            
        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).delete(completion: completion)
            }
        }
    }
    
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forComments comments: [Comment], forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        var commentsWithValues = [Comment]()
        comments.forEach { comment in
            getCaseCommentValuesFor(forCase: clinicalCase, forComment: comment, forType: type) { fetchedComment in
                commentsWithValues.append(fetchedComment)
                if commentsWithValues.count == comments.count {
                    completion(commentsWithValues)
                }
            }
        }
    }
    
    static func getCaseCommentValuesFor(forCase clinicalCase: Case, forComment comment: Comment, forType type: Comment.CommentType, completion: @escaping(Comment) -> Void) {
        var auxComment = comment
        checkIfUserLikedCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { like in
            fetchLikesForCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { likes in
                fetchNumberOfCommentsForCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { comments in
                    checkIfAuthorDidReplyCaseComment(forCase: clinicalCase, forType: type, forCommentUid: comment.id) { comment in
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
    
    static func checkIfUserLikedCaseComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let _ = clinicalCase.groupId {
            COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).getDocument { (snapshot, _) in
                //If the snapshot (document) exists, means current user did like the csae
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        } else {
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        }
    }
    
    static func fetchLikesForCaseComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {
        switch type {
        case .regular:
            let likesRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
        case .group:
            print("we in group")
            let likesRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                print("looking if we get snapshot")
                if let likes = snapshot?.count {
                    print(likes)
                    completion(likes.intValue)
                }
            }
        }
    }
    
    static func fetchNumberOfCommentsForCaseComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {
        switch type {
        case .regular:
            let commentsRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").count
            commentsRef.getAggregation(source: .server) { snapshot, _ in
                if let comments = snapshot?.count {
                    completion(comments.intValue)
                }
            }
        case .group:
            let commentsRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").count
            commentsRef.getAggregation(source: .server) { snapshot, _ in
                if let comments = snapshot?.count {
                    completion(comments.intValue)
                }
            }
        }
    }
    
    static func checkIfAuthorDidReplyCaseComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        switch type {
        case .regular:
            let commentsRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: clinicalCase.ownerUid).limit(to: 1)
            commentsRef.getDocuments { snapshot, _ in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(false)
                    return
                }
                completion(true)
            }
            
        case .group:
            let commentsRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("posts").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: clinicalCase.ownerUid).limit(to: 1)
            commentsRef.getDocuments { snapshot, _ in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    //MARK: - Post
    
    static func getPostCommmentsValuesFor(forPost post: Post, forComments comments: [Comment], forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        var commentsWithValues = [Comment]()
        comments.forEach { comment in
            getPostCommentValuesFor(forPost: post, forComment: comment, forType: type) { fetchedComment in
                commentsWithValues.append(fetchedComment)
                if commentsWithValues.count == comments.count {
                    completion(commentsWithValues)
                }
            }
        }
    }
    
    static func getPostCommentValuesFor(forPost post: Post, forComment comment: Comment, forType type: Comment.CommentType, completion: @escaping(Comment) -> Void) {
        var auxComment = comment
        checkIfUserLikedPostComment(forPost: post, forType: type, forCommentUid: comment.id) { like in
            fetchLikesForPostComment(forPost: post, forType: type, forCommentUid: comment.id) { likes in
                fetchNumberOfCommentsForPostComment(forPost: post, forType: type, forCommentUid: comment.id) { comments in
                    checkIfAuthorDidReplyComment(forPost: post, forType: type, forCommentUid: comment.id) { comment in
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

    static func fetchLikesForPostComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {
        switch type {
        case .regular:
            let likesRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
        case .group:
            print("we in group")
            let likesRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                print("looking if we get snapshot")
                if let likes = snapshot?.count {
                    print(likes)
                    completion(likes.intValue)
                }
            }
        }
    }
    
    static func fetchNumberOfCommentsForPostComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Int) -> Void) {
        switch type {
        case .regular:
            let commentsRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").count
            commentsRef.getAggregation(source: .server) { snapshot, _ in
                if let comments = snapshot?.count {
                    completion(comments.intValue)
                }
            }
        case .group:
            let commentsRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("comments").count
            commentsRef.getAggregation(source: .server) { snapshot, _ in
                if let comments = snapshot?.count {
                    completion(comments.intValue)
                }
            }
        }
    }
    
    static func checkIfAuthorDidReplyComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        switch type {
        case .regular:
            let commentsRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: post.ownerUid).limit(to: 1)
            commentsRef.getDocuments { snapshot, _ in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    print("no comment")
                    completion(false)
                    return
                }
                print("has comment")
                completion(true)
            }
            
        case .group:
            let commentsRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("comments").whereField("uid", isEqualTo: post.ownerUid).limit(to: 1)
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
    
    static func checkIfUserLikedPostComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let _ = post.groupId {
            COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        } else {
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        }
    }
    
    //MARK: - Comment Reply
    
    static func checkIfUserLikedPostCommentReply(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let _ = post.groupId {
            COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        } else {
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        }
    }
    
    static func fetchLikesForPostCommentReply(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Int) -> Void) {
        switch type {
        case .regular:
            let likesRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
        case .group:
            let likesRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
        }
    }
    
    static func getPostReplyCommentValuesFor(forPost post: Post, forComment comment: Comment, forType type: Comment.CommentType, forReply reply: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = reply
        checkIfUserLikedPostCommentReply(forPost: post, forType: type, forCommentUid: comment.id, forReplyId: reply.id) { didLike in
            fetchLikesForPostCommentReply(forPost: post, forType: type, forCommentUid: comment.id, forReplyId: reply.id) { likes in
                auxComment.likes = likes
                auxComment.didLike = didLike
                auxComment.isAuthor = post.ownerUid == reply.uid ? true : false
                completion(auxComment)
            }
        }
    }

    static func getPostRepliesCommmentsValuesFor(forPost post: Post, forComment comment: Comment, forReplies replies: [Comment], forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        var repliesWithValues = [Comment]()
        
        replies.forEach { reply in
            getPostReplyCommentValuesFor(forPost: post, forComment: comment, forType: type, forReply: reply) { fetchedReplies in
                repliesWithValues.append(fetchedReplies)
                if repliesWithValues.count == replies.count {
                    completion(repliesWithValues)
                }
            }
        }
    }

    static func likePostReplyComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
            }
        }
    }
    
    static func unlikePostReplyComment(forPost post: Post, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        switch type {
        case .regular:
            let commentRef = COLLECTION_POSTS.document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).delete(completion: completion)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(post.groupId!).collection("posts").document(post.postId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).delete(completion: completion)
                //COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(post.postId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
                
            }
        }
    }
    
    
    
    
    
    
    static func getCaseRepliesCommmentsValuesFor(forCase clinicalCase: Case, forComment comment: Comment, forReplies replies: [Comment], forType type: Comment.CommentType, completion: @escaping([Comment]) -> Void) {
        var repliesWithValues = [Comment]()
        
        replies.forEach { reply in
            getCaseReplyCommentValuesFor(forCase: clinicalCase, forComment: comment, forType: type, forReply: reply) { fetchedReplies in
                repliesWithValues.append(fetchedReplies)
                if repliesWithValues.count == replies.count {
                    completion(repliesWithValues)
                }
            }
        }
    }
    
    
    
    
    static func getCaseReplyCommentValuesFor(forCase clinicalCase: Case, forComment comment: Comment, forType type: Comment.CommentType, forReply reply: Comment, completion: @escaping(Comment) -> Void) {
        var auxComment = reply
        checkIfUserLikedCaseCommentReply(forCase: clinicalCase, forType: type, forCommentUid: comment.id, forReplyId: reply.id) { didLike in
            fetchLikesForCaseCommentReply(forCase: clinicalCase, forType: type, forCommentUid: comment.id, forReplyId: reply.id) { likes in
                auxComment.likes = likes
                auxComment.didLike = didLike
                auxComment.isAuthor = clinicalCase.ownerUid == reply.uid ? true : false
                completion(auxComment)
            }
        }
    }
    
    static func checkIfUserLikedCaseCommentReply(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let _ = clinicalCase.groupId {
            COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        } else {
            COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        }
    }
    
    static func fetchLikesForCaseCommentReply(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(Int) -> Void) {
        switch type {
        case .regular:
            let likesRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
        case .group:
            let likesRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").count
            likesRef.getAggregation(source: .server) { snapshot, _ in
                if let likes = snapshot?.count {
                    completion(likes.intValue)
                }
            }
        }
    }
    
    static func uploadCaseReplyComment(comment: String, commentId: String, clinicalCase: Case, user: User, type: Comment.CommentType, completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document()
            let data: [String: Any] = ["uid": uid,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date())]
            commentRef.setData(data) { _ in
                completion(commentRef.documentID)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("posts").document(clinicalCase.caseId).collection("comments").document(commentId).collection("comments").document()
            let data: [String: Any] = ["uid": uid,
                                       "comment": comment,
                                       "id": commentRef.documentID,
                                       "timestamp": Timestamp(date: Date())]
            commentRef.setData(data) { _ in
                completion(commentRef.documentID)
            }
        }
    }
    
    static func unlikeCaseReplyComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).delete(completion: completion)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.delete { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).delete(completion: completion)
              
            }
        }
    }
    
    static func likeCaseReplyComment(forCase clinicalCase: Case, forType type: Comment.CommentType, forCommentUid commentUid: String, forReplyId replyId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        switch type {
        case .regular:
            let commentRef = COLLECTION_CASES.document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-comment-likes").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
            }
        case .group:
            let commentRef = COLLECTION_GROUPS.document(clinicalCase.groupId!).collection("cases").document(clinicalCase.caseId).collection("comments").document(commentUid).collection("comments").document(replyId).collection("likes").document(uid)
            commentRef.setData(likeData) { _ in
                COLLECTION_USERS.document(uid).collection("user-group-comments-like").document(clinicalCase.caseId).collection("comment-likes").document(commentUid).collection("comment-likes").document(replyId).setData(likeData, completion: completion)
            }
        }
    }
}
