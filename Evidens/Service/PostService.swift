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

struct PostService {

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
                    "disciplines": viewModel.disciplines.map { $0.rawValue },
                    "kind": viewModel.kind.rawValue,
                    "privacy": viewModel.privacy.rawValue] as [String: Any]
        

        if let hashtags = viewModel.hashtags {
            post["hashtags"] = hashtags.map { $0.lowercased() }
        }
        
        if let reference = viewModel.reference {
            post["reference"] = reference.option.rawValue
        }
        
        let ref = COLLECTION_POSTS.document()

        if viewModel.hasImages {
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
                                        DatabaseManager.shared.uploadRecentPost(withUid: ref.documentID, withDate: Date()) { added in
                                            guard added else {
                                                completion(.unknown)
                                                return
                                            }
                                            
                                            completion(nil)
                                        }
                                    }
                                }
                            } else {
                                DatabaseManager.shared.uploadRecentPost(withUid: ref.documentID, withDate: Date()) { added in
                                    guard added else {
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
        } else {
            ref.setData(post) { error in
                if let _ = error {
                    completion(.unknown)
                } else {
                    if let reference = viewModel.reference {
                        addReferenceData(reference, toPostDocument: ref) { error in
                            if let _ = error {
                                completion(.unknown)
                            } else {
                                DatabaseManager.shared.uploadRecentPost(withUid: ref.documentID, withDate: Date()) { added in
                                    guard added else {
                                        completion(.unknown)
                                        return
                                    }
                                    
                                    completion(nil)
                                }
                            }
                        }
                    } else {
                        DatabaseManager.shared.uploadRecentPost(withUid: ref.documentID, withDate: Date()) { added in
                            guard added else {
                                completion(.unknown)
                                return
                            }
                            
                            completion(nil)
                        }
                    }
                    
                }
            }
        }
    }
    
    
    static func fetchReference(forPostId id: String, forReferenceKind kind: ReferenceKind, completion: @escaping(Result<Reference, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = COLLECTION_POSTS.document(id).collection("reference")
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
   
    static func editPost(viewModel: EditPostViewModel, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        var postData = ["post": viewModel.post,
                        "edited": true] as [String : Any]
        
        if let hashtags = viewModel.hashtags {
            postData["hashtags"] = hashtags
        }
        
        COLLECTION_POSTS.document(viewModel.postId).setData(postData, merge: true) { error in
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
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            //Mapping that creates an array for each post
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    static func fetchTopPosts(completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp
        let query = COLLECTION_POSTS.order(by: "timestamp", descending: true).limit(to: 3)
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            //Mapping that creates an array for each post
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    
    static func fetchPostsForYou(user: User, completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp
        let query = COLLECTION_POSTS.whereField("ownerUid", isNotEqualTo: user.uid!).whereField("professions", arrayContainsAny: [user.discipline!]).limit(to: 3)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            //Mapping that creates an array for each post
            #warning("aquí fer dispatch queue")
            var posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            posts.enumerated().forEach { index, post in
                getPostValuesFor(post: post) { post in
                    posts[index] = post
                    if snapshot.count == posts.count {
                        completion(posts)
                    }
                }
                /*
                self.checkIfUserLikedPost(post: post) { like in
                    self.checkIfUserBookmarkedPost(post: post) { bookmark in
                        fetchLikesForPost(postId: post.postId) { likes in
                            posts[index].likes = likes
                            fetchCommentsForPost(postId: post.postId) { comments in
                                posts[index].numberOfComments = comments
                                posts[index].didLike = like
                                posts[index].didBookmark = bookmark
                                if snapshot.count == posts.count {
                                    completion(posts)
                                }
                            }
                        }                   
                    }
                }
                 */
            }
        }
    }
    
    static func deletePost(withPostUid uid: String, completion: @escaping(Bool) -> Void) {
        
    }
    

    
   
    
    static func fetchHomeDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
            
        }
        
        if lastSnapshot == nil {
            // Fetch first group of posts
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).limit(to: 10)
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
            // Append new posts 
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
                
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
    
    static func fetchPostsWithHashtag(_ hashtag: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {

            let firstGroupToFetch = COLLECTION_POSTS.whereField("hashtags", arrayContains: hashtag.lowercased()).limit(to: 10)
            
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
            // Append new posts
            let nextGroupToFetch = COLLECTION_POSTS.whereField("hashtags", arrayContains: hashtag.lowercased()).start(afterDocument: lastSnapshot!).limit(to: 10)
                
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
    
    static func fetchSearchDocumentsForProfession(user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let discipline = user.discipline else {
            completion(.failure(.unknown))
            return
        }
        
         if lastSnapshot == nil {
             // Fetch first group of posts
             let firstGroupToFetch = COLLECTION_POSTS.whereField("disciplines", arrayContains: discipline.rawValue).limit(to: 10)
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
             let nextGroupToFetch = COLLECTION_POSTS.whereField("disciplines", arrayContains: discipline.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                 
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
    
    static func fetchHomePosts(snapshot: QuerySnapshot, completion: @escaping(Result<[Post], FirestoreError>) -> Void) {
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        
        for document in snapshot.documents {
            dispatchGroup.enter()
            
            fetchPost(withPostId: document.documentID) { result in
                switch result {
                case .success(let post):
                    posts.append(post)
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
    
    
    static func checkIfUserHasNewerPostsToDisplay(snapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let snapshot = snapshot else {
            completion(.failure(.unknown))
            return
        }

        let newQuery = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: false).start(afterDocument: snapshot).limit(to: 10)

        newQuery.getDocuments { snapshot, error in
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
    
    /*
    static func fetchRecentPosts(withPostId postId: [String], completion: @escaping([Post]) -> Void) {
        var posts = [Post]()

        postId.forEach { id in
            fetchPost(withPostId: id) { result in
                
                posts.append(post)
                if posts.count == postId.count {
                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(posts)
                }
            }
        }
    }
    */
    
    static func fetchPosts(withPostIds postIds: [String], completion: @escaping(Result<[Post], FirestoreError>) -> Void) {
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        
        for postId in postIds {
            dispatchGroup.enter()
            
            fetchPost(withPostId: postId) { result in
                
                switch result {
                case .success(let post):
                    posts.append(post)
                case .failure(let error):
                    print(error)
                    #warning("Post was not found so maybe its good to remove the reference from the collection of posts from the user")
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(.success(posts))
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Result<Post, FirestoreError>) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.unknown))
                    return
                }
                
                let post = Post(postId: snapshot.documentID, dictionary: data)
                getPostValuesFor(post: post) { postWithValues in
                    completion(.success(postWithValues))
                }
            }
        }
    }
    
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
    
    static func fetchLikesForPost(postId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        let likesRef = COLLECTION_POSTS.document(postId).collection("post-likes").count
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
    
    static func fetchCommentsForPost(postId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        let likesRef = COLLECTION_POSTS.document(postId).collection("comments").count
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
    
    static func getSnapshotForLastPost(_ post: Post, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {

        COLLECTION_POSTS.whereField("id", isEqualTo: post.postId).limit(to: 1).getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                completion(.success(snapshot))
            }
        }
    }
    
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp & user uid
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
            //.order(by: "timestamp", descending: false)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
        
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            //Order posts by timestamp
            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            
            completion(posts)
        }
    }
    
    #warning("needs review and addd result<>")
    static func fetchTopPostsForTopic(topic: String, completion: @escaping([Post]) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        let query = COLLECTION_POSTS.whereField("professions", arrayContains: topic).limit(to: 3)
        query.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            posts.enumerated().forEach { index, post in
                dispatchGroup.enter()
                getPostValuesFor(post: post) { postWithValues in
                    posts[index] = postWithValues
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(posts)
            }
        }
    }
    
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

    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData(likeData) { _ in
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).setData(likeData, completion: completion)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).setData(likeData) { error in
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
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).delete { error in
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
    
    static func bookmark(post: Post, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        let bookmarkData = ["timestamp": Timestamp(date: Date())]
        
        dispatchGroup.enter()
        COLLECTION_POSTS.document(post.postId).collection("post-bookmarks").document(uid).setData(bookmarkData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(post.postId).setData(bookmarkData) { error in
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
    
    static func unbookmark(post: Post, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_POSTS.document(post.postId).collection("post-bookmarks").document(uid).delete { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(post.postId).delete { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
    }
    
    static func bookmarkPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let bookmarkData = ["timestamp": Timestamp(date: Date())]
        //Update post bookmark collection to track bookmarks for a particular post
        COLLECTION_POSTS.document(post.postId).collection("post-bookmarks").document(uid).setData(bookmarkData) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(post.postId).setData(bookmarkData, completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        guard post.likes > 0 else { return }
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func unbookmarkPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        COLLECTION_POSTS.document(post.postId).collection("post-bookmarks").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(post.postId).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).getDocument { snapshot, error in
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
    
    static func checkIfUserBookmarkedPost(post: Post, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        COLLECTION_USERS.document(uid).collection("user-post-bookmarks").document(post.postId).getDocument { snapshot, error in
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
    
    static func getAllLikesFor(post: Post, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            COLLECTION_POSTS.document(post.postId).collection("post-likes").limit(to: 30).getDocuments { snapshot, error in
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
            COLLECTION_POSTS.document(post.postId).collection("post-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, error in
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
    
    static func updateUserFeedAfterFollowing(userUid: String, didFollow: Bool) {
        /*
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query =  COLLECTION_POSTS.whereField("ownerUid", isEqualTo: userUid as Any)
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data())})
            
            //Use docIDs to update user feed structure
            posts.forEach { post in
                if didFollow {
                    COLLECTION_USERS.document(uid).collection("user-home-feed").document(post.postId).setData(["timestamp": post.timestamp])
                } else {
                    COLLECTION_USERS.document(uid).collection("user-home-feed").document(post.postId).delete()
                }
            }
        }
         */
    }
    
    private static func updateUserFeedAfterPost(postId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-home-feed").document(postId).setData(["timestamp": Timestamp(date: Date())])
            }
            
            COLLECTION_USERS.document(uid).collection("user-home-feed").document(postId).setData(["timestamp": Timestamp(date: Date())])
        }
    }
    
    static func fetchBookmarkedPostDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-post-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
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
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-post-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
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
    
    /*
    static func fetchBookmarkedPosts(snapshot: QuerySnapshot, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        snapshot.documents.forEach({ document in
            let data = document.data()
            
            fetchPost(withPostId: document.documentID) { result in
                switch result {
                case .success(let success):
                    <#code#>
                case .failure(let failure):
                    <#code#>
                }
                posts.append(post)
                posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                completion(posts)
            }
        })
    }
     */
}
