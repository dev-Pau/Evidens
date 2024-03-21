//
//  PostService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

/// A service used to interface with FirebaseFirestore for posts.
struct PostService { }

//MARK: - Fetch Operations

extension PostService {
    
    /// Fetches an array of posts based on a list of post IDs.
    ///
    /// - Parameters:
    ///   - postIds: The array of post IDs for which posts are to be fetched.
    ///   - completion: A completion handler that receives the fetched array of posts or an error.
    static func fetchPosts(withPostIds postIds: [String], completion: @escaping(Result<[Post], FirestoreError>) -> Void) {
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        
        for postId in postIds {
            dispatchGroup.enter()
            
            fetchPost(withPostId: postId) { result in
                
                switch result {
                case .success(let post):
                    if post.visible != .regular {
                        self.removePostReference(withId: postId)
                    } else {
                        posts.append(post)
                    }
                case .failure(let error):
                    if error == .notFound {
                        self.removePostReference(withId: postId)
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(.success(posts))
        }
    }
    
    /// Fetches a specific post from the Firestore database.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post to be fetched.
    ///   - completion: A completion handler that takes a `Result` enum containing either the fetched `Post` or a `FirestoreError` in case of failure.
    static func fetchPost(withPostId postId: String, completion: @escaping(Result<Post, FirestoreError>) -> Void) {
        K.FirestoreCollections.COLLECTION_POSTS.document(postId).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.notFound))
                    return
                }

                let post = Post(postId: snapshot.documentID, dictionary: data)
                getPostValuesFor(post: post) { postWithValues in
                    completion(.success(postWithValues))
                }
            }
        }
    }
    
    /// Fetches the number of likes for a specific notification post from the Firestore database.
    ///
    /// - Parameters:
    ///   - postId: The ID of the notification post to fetch likes for.
    ///   - completion: A completion handler that takes an integer representing the number of likes fetched.
    static func getLikesForNotificationPost(withId postId: String, completion: @escaping(Int) -> Void) {
        
        var postLikes = 0
        
        let date = DataService.shared.getLastDate(forContentId: postId, withKind: .likePost)
        fetchLikesForPost(postId: postId, startingAt: date) { result in
            switch result {
                
            case .success(let likes):
                postLikes = likes
            case .failure(_):
                postLikes = 0
            }
            
            completion(postLikes)
        }
    }
    
    /// Fetches a plain Post from Firestore with the specified post ID.
    /// - Parameters:
    ///   - postId: The unique identifier of the post to fetch.
    ///   - completion: A completion handler that receives a result containing either the fetched Post or an error.
    static func getPlainPost(withPostId postId: String, completion: @escaping(Result<Post, FirestoreError>) -> Void) {
        
        K.FirestoreCollections.COLLECTION_POSTS.document(postId).getDocument { snapshot, error in

            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.notFound))
                    return
                }
                
                let post = Post(postId: snapshot.documentID, dictionary: data)
                completion(.success(post))
            }
        }
    }
    
    /// Fetches a group of plain Posts from Firestore with the specified post IDs.
    /// - Parameters:
    ///   - postIds: The unique identifier of the post to fetch.
    ///   - completion: A completion handler that receives a result containing either the fetched Posts or an error.
    static func getPlainPosts(withPostIds postIds: [String], completion: @escaping(Result<[Post], FirestoreError>) -> Void) {
        
        var posts = [Post]()
        let group = DispatchGroup()
        
        for postId in postIds {
            group.enter()
            
            getPlainPost(withPostId: postId) { result in
                switch result {
                case .success(let post):
                    posts.append(post)
                case .failure(_):
                    break
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(posts))
        }
    }
    
    /// Fetches the number of visible comments for a specific post.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post for which to fetch the comments count.
    ///   - completion: A completion handler that receives a `Result` enum containing either the comments count or a `FirestoreError`.
    static func fetchCommentsForPost(postId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        let likesRef = K.FirestoreCollections.COLLECTION_POSTS.document(postId).collection("comments").whereField("visible", isNotEqualTo: Visible.deleted.rawValue).count

        likesRef.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                if let comments = snapshot?.count {
                    completion(.success(comments.intValue))
                } else {
                    completion(.success(0))
                }
            }
        }
    }
    
    /// Fetches the bookmarked post documents for a user.
    ///
    /// - Parameters:
    ///   - lastSnapshot: The last document snapshot retrieved, used for pagination.
    ///   - completion: A completion handler that receives a result containing the query snapshot of bookmarked post documents.
    static func fetchPostBookmarkDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }

        if lastSnapshot == nil {
            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                
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
            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                
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
    
    
    /// Fetches suggested posts for the given user based on their discipline.
    ///
    /// - Parameters:
    ///   - user: The user for whom to fetch suggested posts.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[Post], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `Post` objects containing the suggested posts,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchSuggestedPosts(forUser user: User, completion: @escaping(Result<[Post], FirestoreError>) -> Void) {
        guard let discipline = user.discipline else {
            
            completion(.failure(.unknown))
            return
            
        }

        let query = K.FirestoreCollections.COLLECTION_POSTS.whereField("uid", isNotEqualTo: user.uid!).whereField("disciplines", arrayContainsAny: [discipline.rawValue]).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).limit(to: 3)
        query.getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let group = DispatchGroup()
                var posts = snapshot.documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
                for (index, post) in posts.enumerated() {
                    group.enter()
                    getPostValuesFor(post: post) { post in
                        posts[index] = post
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(posts))
                }
            }
        }
    }
    
    /// Fetches the reference for a specific post with the given ID and reference kind.
    ///
    /// - Parameters:
    ///   - id: The ID of the post for which to fetch the reference.
    ///   - kind: The kind of reference to fetch (e.g., .article, .book, etc.).
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<Reference, FirestoreError>`.
    ///                 The result will be either `.success` with a `Reference` object containing the fetched reference,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchReference(forPostId id: String, forReferenceKind kind: ReferenceKind, completion: @escaping(Result<Reference, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = K.FirestoreCollections.COLLECTION_POSTS.document(id).collection("reference")
        ref.getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let document = snapshot?.documents.first else {
                    completion(.failure(.unknown))
                    return
                }
                let data = document.data()
                let reference = Reference(dictionary: data, kind: kind)
                completion(.success(reference))
            }
        }
    }
    
    /// Fetches additional values for the given post.
    ///
    /// - Parameters:
    ///   - post: The post for which to fetch additional values.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Post`, containing the post with additional values fetched.
    static func getPostValuesFor(post: Post, completion: @escaping(Post) -> Void) {
        var auxPost = post
        let group = DispatchGroup()
        
        group.enter()
        checkIfUserLikedPost(post: post) { result in
            switch result {
            case .success(let didLike):
                auxPost.didLike = didLike
            case .failure(_):
                auxPost.didLike = false
            }

            group.leave()
        }
        
        group.enter()
        checkIfUserBookmarkedPost(post: post) { result in
            switch result {
            case .success(let didBookmark):
                auxPost.didBookmark = didBookmark
            case .failure(_):
                auxPost.didBookmark = false
            }
            
          group.leave()
        }
        
        group.enter()
        fetchLikesForPost(postId: post.postId) { result in
            switch result {
            case .success(let likes):
                auxPost.likes = likes
            case .failure(_):
                auxPost.likes = 0
            }

            group.leave()
        }
        
        
        group.enter()
        fetchCommentsForPost(postId: post.postId) { result in
            switch result {
            case .success(let comments):
                auxPost.numberOfComments = comments
            case .failure(_):
                auxPost.numberOfComments = 0
            }

            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(auxPost)
        }
    }
    
    /// Fetches home documents for the user's home feed.
    ///
    /// - Parameters:
    ///   - lastSnapshot: The last snapshot of the previously fetched documents. Pass `nil` to fetch the first set of documents.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with a `QuerySnapshot` containing the fetched documents,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchPostDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
            
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-network").order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                
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
            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-network").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                    return
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
    
    /// Fetches posts containing a specific hashtag.
    ///
    /// - Parameters:
    ///   - hashtag: The hashtag to search for.
    ///   - lastSnapshot: The last document snapshot retrieved, used for pagination.
    ///   - completion: A completion handler that receives a result containing the query snapshot of posts.
    static func fetchPostsWithHashtag(_ hashtag: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {

            let firstGroupToFetch = K.FirestoreCollections.COLLECTION_POSTS.whereField("hashtags", arrayContains: hashtag.lowercased()).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).limit(to: 10)
            
            firstGroupToFetch.getDocuments { snapshot, error in
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
            let nextGroupToFetch = K.FirestoreCollections.COLLECTION_POSTS.whereField("hashtags", arrayContains: hashtag.lowercased()).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                
            nextGroupToFetch.getDocuments { snapshot, error in
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
    
    /// Fetches search documents for a specific profession.
    ///
    /// - Parameters:
    ///   - discipline: The discipline used to fetch search documents.
    ///   - lastSnapshot: The last snapshot of the previously fetched documents. Pass `nil` to fetch the first set of documents.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with a `QuerySnapshot` containing the fetched documents,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchSearchDocumentsForDiscipline(discipline: Discipline, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
         if lastSnapshot == nil {
             // Fetch first group of posts
             let firstGroupToFetch = K.FirestoreCollections.COLLECTION_POSTS.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).limit(to: 10)
             firstGroupToFetch.getDocuments { snapshot, error in
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
             let nextGroupToFetch = K.FirestoreCollections.COLLECTION_POSTS.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                 
             nextGroupToFetch.getDocuments { snapshot, error in
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
    
    /// Fetches home posts based on the given snapshot.
    ///
    /// - Parameters:
    ///   - snapshot: The snapshot containing the documents to fetch.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[Post], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `Post` objects containing the fetched posts,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchPosts(snapshot: QuerySnapshot, completion: @escaping(Result<[Post], FirestoreError>) -> Void) {
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        
        for document in snapshot.documents {
            dispatchGroup.enter()
            fetchPost(withPostId: document.documentID) { result in
                switch result {
                case .success(let post):
                    if post.visible != .regular {
                        self.removePostReference(withId: post.postId)
                    } else {
                        posts.append(post)
                    }
                case .failure(_):
                    break
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(.success(posts))
        }
    }
    
    /// Fetches all likes for a post.
    ///
    /// - Parameters:
    ///   - post: The Post for which to fetch the likes.
    ///   - lastSnapshot: An optional parameter representing the last snapshot of the previous fetch, if any.
    ///   - completion: A closure to be called when the fetch is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the fetched `QuerySnapshot` if successful,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func getAllLikesFor(post: Post, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            K.FirestoreCollections.COLLECTION_POSTS.document(post.postId).collection("post-likes").limit(to: 30).getDocuments { snapshot, error in
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
            K.FirestoreCollections.COLLECTION_POSTS.document(post.postId).collection("post-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, error in
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
}

//MARK: - Delete Operations

extension PostService {
    
    /// Removes a reference to a post from the user's home feed collection and bookmarks.
    ///
    /// - Parameters:
    ///   - id: The ID of the post to be removed from the user's home feed.
    static func removePostReference(withId id: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-network").document(id).delete()
        K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(id).delete()
    }
}

//MARK: - Miscellaneous

extension PostService {
    
    /// Fetches the number of likes for a specific post.
    ///
    /// - Parameters:
    ///   - postId: The ID of the post for which to fetch the likes count.
    ///   - completion: A completion handler that receives a `Result` enum containing either the likes count or a `FirestoreError`.
    static func fetchLikesForPost(postId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        let likesRef = K.FirestoreCollections.COLLECTION_POSTS.document(postId).collection("post-likes").count
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
    
    /// Fetches the count of likes for a specific post, optionally starting from a certain date.
    ///
    /// - Parameters:
    ///   - postId: The unique identifier of the post.
    ///   - date: An optional `Date` representing the starting date to fetch likes from.
    ///   - completion: A closure that receives a result containing the like count or an error.
    static func fetchLikesForPost(postId: String, startingAt date: Date?, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        if let date {
            let timestamp = Timestamp(date: date)
            let likesRef = K.FirestoreCollections.COLLECTION_POSTS.document(postId).collection("post-likes").whereField("timestamp", isGreaterThan: timestamp).count
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
        } else {
            let likesRef = K.FirestoreCollections.COLLECTION_POSTS.document(postId).collection("post-likes").count
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
    
    /// Fetches additional values for an array of posts.
    ///
    /// - Parameters:
    ///   - posts: The array of posts for which to fetch additional values.
    ///   - completion: A completion handler that receives the updated array of posts with additional values.
    static func getPostValuesFor(posts: [Post], completion: @escaping([Post]) -> Void) {
        var auxPosts = posts
        let dispatchGroup = DispatchGroup()
        
        posts.enumerated().forEach { index, post in
            dispatchGroup.enter()
            getPostValuesFor(post: post) { postWithValues in
                auxPosts[index] = postWithValues
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(auxPosts)
        }
    }
    
    /// Checks if the current user has liked a post.
    ///
    /// - Parameters:
    ///   - post: The post to check for likes.
    ///   - completion: A completion handler that receives a result indicating if the user liked the post.
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-likes").document(post.postId).getDocument { snapshot, error in
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
    
    /// Checks if the current user has bookmarked a post.
    ///
    /// - Parameters:
    ///   - post: The post to check for bookmarks.
    ///   - completion: A completion handler that receives a result indicating if the user bookmarked the post.
    static func checkIfUserBookmarkedPost(post: Post, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(post.postId).getDocument { snapshot, error in
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
}

// MARK: - Add Operations

extension PostService {
    
    /// Adds a new post to the database.
    ///
    /// - Parameters:
    ///   - viewModel: The view model containing post details.
    ///   - completion: A closure to be called when the post is added.
    ///                 It takes a single parameter of type `FirestoreError?`.
    ///                 If there is an error during the process, it will be returned in the `FirestoreError`.
    static func addPost(viewModel: AddPostViewModel, completion: @escaping(FirestoreError?) -> Void) {

        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard let text = viewModel.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            completion(.unknown)
            return
        }
        
        var post: [String: Any] = ["post": text,
                    "timestamp": Timestamp(date: Date()),
                    "uid": uid,
                    "visible": PostVisibility.regular.rawValue,
                    "disciplines": viewModel.disciplines.map { $0.rawValue },
                    "kind": viewModel.kind.rawValue,
                    "privacy": viewModel.privacy.rawValue] as [String: Any]

        if let hashtags = viewModel.hashtags, !hashtags.isEmpty {
            post["hashtags"] = hashtags.map { $0.lowercased() }
        }
        
        if let reference = viewModel.reference {
            post["reference"] = reference.option.rawValue
        }
        
        let ref = K.FirestoreCollections.COLLECTION_POSTS.document()
        
        switch viewModel.kind {
            
        case .text, .link:

            if viewModel.kind == .link, let link = viewModel.links.first {
                post["linkUrl"] = link
            }
            
            ref.setData(post) { error in
                if let _ = error {
                    completion(.unknown)
                } else {
                    if let reference = viewModel.reference {
                        addReferenceData(reference, toPostDocument: ref) { error in
                            if let _ = error {
                                completion(.unknown)
                            } else {
                                DatabaseManager.shared.addRecentPost(withId: ref.documentID, withDate: Date()) { error in
                                    guard error == nil else {
                                        completion(.unknown)
                                        return
                                    }
                                    
                                    completion(nil)
                                }
                            }
                        }
                    } else {
                        DatabaseManager.shared.addRecentPost(withId: ref.documentID, withDate: Date()) { added in
                            guard error == nil else {
                                completion(.unknown)
                                return
                            }
                            
                            completion(nil)
                        }
                    }
                }
            }
        case .image:
            StorageManager.addImages(toPostId: ref.documentID, viewModel.images) { result in
                switch result {
                case .success(let imageUrl):
                    post["imageUrl"] = imageUrl
                    
                    ref.setData(post) { error in
                        if let _ = error {
                            completion(.unknown)
                        } else {
                            if let reference = viewModel.reference {
                                addReferenceData(reference, toPostDocument: ref) { error in
                                    if let _ = error {
                                        completion(.unknown)
                                    } else {
                                        DatabaseManager.shared.addRecentPost(withId: ref.documentID, withDate: Date()) { error in
                                            guard error == nil else {
                                                completion(.unknown)
                                                return
                                            }
                                            
                                            completion(nil)
                                        }
                                    }
                                }
                            } else {
                                DatabaseManager.shared.addRecentPost(withId: ref.documentID, withDate: Date()) { error in
                                    guard error == nil else {
                                        completion(.unknown)
                                        return
                                    }
                                    
                                    completion(nil)
                                }
                            }
                            
                        }
                    }
                    
                case .failure(_):
                    completion(.unknown)
                }
            }
        }
    }
    
    /// Adds reference data to a post document.
    ///
    /// - Parameters:
    ///   - reference: The reference to be added.
    ///   - document: The document reference of the post to which the reference data will be added.
    ///   - completion: A closure to be called when the addition process is completed.
    ///                 It takes a single parameter of type `FirestoreError?`.
    ///                 If there is an error during the addition process, the `FirestoreError` will be passed to the closure.
    ///                 Otherwise, it will be `nil`.
    static func addReferenceData(_ reference: Reference, toPostDocument document: DocumentReference, completion: @escaping (FirestoreError?) -> Void) {
        let referenceData: [String: Any] = ["content": reference.referenceText]
        document.collection("reference").addDocument(data: referenceData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}


//MARK: - Edit Operations

extension PostService {
    
    /// Edits a post with the provided view model.
    ///
    /// - Parameters:
    ///   - viewModel: The view model containing the updated post details.
    ///   - completion: A closure to be called when the editing process is completed.
    ///                 It takes a single parameter of type `FirestoreError?`.
    ///                 If there is an error during the editing process, the `FirestoreError` will be passed to the closure.
    ///                 Otherwise, it will be `nil`.
    static func editPost(viewModel: EditPostViewModel, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        var postData = ["post": viewModel.postText.trimmingCharacters(in: .whitespacesAndNewlines),
                        "edited": true,
                        "kind": viewModel.kind.rawValue] as [String : Any]
        
        if let hashtags = viewModel.hashtags, !hashtags.isEmpty {
            postData["hashtags"] = hashtags
        } else {
            postData["hashtags"] = FieldValue.delete()
        }

         if viewModel.kind == .link, let link = viewModel.links.first {
             postData["linkUrl"] = link
         }

        K.FirestoreCollections.COLLECTION_POSTS.document(viewModel.postId).updateData(postData) { error in
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
    
    /// Deletes a post with the given ID from the Firestore database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the post to be deleted.
    ///   - completion: A closure that will be called after the delete operation is attempted.
    ///                 If the operation is successful, the completion will be called with `nil`.
    ///                 If an error occurs during the operation, the completion will be called with an appropriate `FirestoreError`.
    static func deletePost(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let deletedPost = ["visible": PostVisibility.deleted.rawValue]
        
        K.FirestoreCollections.COLLECTION_POSTS.document(id).setData(deletedPost, merge: true) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                DatabaseManager.shared.deleteRecentPost(withId: id) { error in
                    if let _ = error {
                        completion(.unknown)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
}

//MARK: - Miscellaneous

extension PostService {
    
    /// Adds a like to a post and updates the user's likes.
    ///
    /// - Parameters:
    ///   - id: The ID of the post to be liked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func likePost(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        let batch = Firestore.firestore().batch()
        
        let postRef = K.FirestoreCollections.COLLECTION_POSTS.document(id).collection("post-likes").document(uid)
        let userRef = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-likes").document(id)
        
        batch.setData(likeData, forDocument: postRef)
        batch.setData(likeData, forDocument: userRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Removes a like from a post and updates the user's likes.
    ///
    /// - Parameters:
    ///   - id: The ID of the post to be unliked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func unlikePost(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }

        let batch = Firestore.firestore().batch()
        
        let postRef = K.FirestoreCollections.COLLECTION_POSTS.document(id).collection("post-likes").document(uid)
        let userRef = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-likes").document(id)

        batch.deleteDocument(postRef)
        batch.deleteDocument(userRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Adds a bookmark to a post and updates the user's bookmarks.
    ///
    /// - Parameters:
    ///   - id: The ID of the post to be bookmarked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func bookmarkPost(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let batch = Firestore.firestore().batch()
        
        let bookmarkData = ["timestamp": Timestamp(date: Date())]
        
        let postRef = K.FirestoreCollections.COLLECTION_POSTS.document(id).collection("post-bookmarks").document(uid)
        let userRef = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(id)
        
        batch.setData(bookmarkData, forDocument: postRef)
        batch.setData(bookmarkData, forDocument: userRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Removes a bookmark from a post and updates the user's bookmarks.
    ///
    /// - Parameters:
    ///   - id: The ID of the post to be unbookmarked.
    ///   - completion: A completion handler that indicates the success or failure of the operation.
    static func unbookmarkPost(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let batch = Firestore.firestore().batch()
        
        
        let postRef = K.FirestoreCollections.COLLECTION_POSTS.document(id).collection("post-bookmarks").document(uid)
        let userRef = K.FirestoreCollections.COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(id)

        batch.deleteDocument(postRef)
        batch.deleteDocument(userRef)
        
        batch.commit { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}
