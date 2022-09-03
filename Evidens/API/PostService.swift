//
//  PostService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/21.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadTextPost(post: String, type: Post.PostType, privacy: Post.PrivacyOptions, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "ownerUid": uid,
                    "comments": 0,
                    "shares": 0,
                    "type": type.rawValue,
                    "privacy": privacy.rawValue,
                    "bookmarks": 0,
                    "profession": user.profession as Any,
                    "speciality": user.speciality as Any,
                    "ownerFirstName": user.firstName as Any,
                    "ownerCategory": user.category.userCategoryString as Any,
                    "ownerLastName": user.lastName as Any,
                    "ownerImageUrl": user.profileImageUrl as Any]
                   
        
        let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
        
        DatabaseManager.shared.uploadRecentPost(withUid: docRef.documentID, withDate: Date()) { uploaded in
            print("Post uploaded to recents")
        }
        
        self.updateUserFeedAfterPost(postId: docRef.documentID)
    }
    
    static func uploadSingleImagePost(post: String, type: Post.PostType, privacy: Post.PrivacyOptions, postImageUrl: [String]?, imageHeight: CGFloat, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "ownerUid": uid,
                    "comments": 0,
                    "shares": 0,
                    "type": type.rawValue,
                    "privacy": privacy.rawValue,
                    "bookmarks": 0,
                    "profession": user.profession as Any,
                    "speciality": user.speciality as Any,
                    "ownerFirstName": user.firstName as Any,
                    "ownerCategory": user.category.userCategoryString as Any,
                    "ownerLastName": user.lastName as Any,
                    "imageHeight": imageHeight,
                    "ownerImageUrl": user.profileImageUrl as Any,
                    "postImageUrl": postImageUrl as Any] as [String : Any]

        let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
        
        DatabaseManager.shared.uploadRecentPost(withUid: docRef.documentID, withDate: Date()) { uploaded in
            print("Post uploaded to recents")
        }
        
        self.updateUserFeedAfterPost(postId: docRef.documentID)
    }
    
    
    static func uploadPost(post: String, type: Post.PostType, privacy: Post.PrivacyOptions, postImageUrl: [String]?, user: User, completion: @escaping(FirestoreCompletion)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "ownerUid": uid,
                    "comments": 0,
                    "shares": 0,
                    "type": type.rawValue,
                    "privacy": privacy.rawValue,
                    "bookmarks": 0,
                    "profession": user.profession as Any,
                    "speciality": user.speciality as Any,
                    "ownerFirstName": user.firstName as Any,
                    "ownerCategory": user.category.userCategoryString as Any,
                    "ownerLastName": user.lastName as Any,
                    "ownerImageUrl": user.profileImageUrl as Any,
                    "postImageUrl": postImageUrl as Any] as [String : Any]
                   
        
        let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
        
        DatabaseManager.shared.uploadRecentPost(withUid: docRef.documentID, withDate: Date()) { uploaded in
            print("Post uploaded to recents")
        }
        
        
        self.updateUserFeedAfterPost(postId: docRef.documentID)
    }
    
    static func editPost(withPostUid postUid: String, withNewText text: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
         
        let postData = ["post": text,
                        "edited": true] as [String : Any]
        
        COLLECTION_POSTS.document(postUid).setData(postData, merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            } else {
                completion(true)
                return
            }
        }
    }
    
    static func uploadDocumentPost(post: String, documentURL: String, documentTitle: String, documentPages: Int, user: User, type: Post.PostType, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "ownerUid": uid,
                    "comments": 0,
                    "shares": 0,
                    "type": type.rawValue,
                    "bookmarks": 0,
                    "ownerFirstName": user.firstName as Any,
                    "ownerCategory": user.category.userCategoryString as Any,
                    "ownerLastName": user.lastName as Any,
                    "ownerImageUrl": user.profileImageUrl as Any,
                    "documentPages": documentPages as Any,
                    "documentTitle": documentTitle as Any,
                    "postDocumentUrl": documentURL as Any] as [String : Any]
                   
        let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
        
        DatabaseManager.shared.uploadRecentPost(withUid: docRef.documentID, withDate: Date()) { uploaded in
            print("Post uploaded to recents")
        }
        
        self.updateUserFeedAfterPost(postId: docRef.documentID)
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
    
    static func deletePost(withPostUid uid: String, completion: @escaping(Bool) -> Void) {
        
    }
    
    static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()
        
        COLLECTION_USERS.document(uid).collection("user-home-feed").getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    
                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    completion(posts)
                }
            })
        }
    }
    
    static func fetchHomeDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if lastSnapshot == nil {
            print("first")
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).limit(to: 3)
            firstGroupToFetch.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            print("next group")
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 1)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    
    static func fetchHomePosts(snapshot: QuerySnapshot, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        snapshot.documents.forEach({ document in
            fetchPost(withPostId: document.documentID) { post in
                print("post fetched is \(post)")
                posts.append(post)
                posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                completion(posts)
            }
        })
    }
    
    static func fetchRecentPosts(withPostId postId: [String], completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        postId.forEach { id in
            fetchPost(withPostId: id) { post in
                posts.append(post)
                
                posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                
                completion(posts)
                
            }
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postId: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        //Fetch posts by filtering according to timestamp & user uid
        let query =  COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
            //.order(by: "timestamp", descending: false)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
        
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            //Order posts by timestamp
            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            
            completion(posts)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Add a new like to the post
        COLLECTION_POSTS.document(post.postId).updateData(["likes" : post.likes + 1])
        
        //Update posts likes collection to track likes for a particular post
        COLLECTION_POSTS.document(post.postId).collection("posts-likes").document(uid).setData([:]) { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func bookmarkPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["bookmarks" : post.numberOfBookmarks + 1])
        
        //Update post bookmark collection to track bookmarks for a particular post
        COLLECTION_POSTS.document(post.postId).collection("posts-bookmarks").document(uid).setData([:]) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes" : post.likes - 1])

        COLLECTION_POSTS.document(post.postId).collection("posts-likes").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func unbookmarkPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.numberOfBookmarks > 0 else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["bookmarks" : post.numberOfBookmarks - 1])
        
        COLLECTION_POSTS.document(post.postId).collection("posts-bookmarks").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).delete(completion: completion)
        }
        
        
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func checkIfUserBookmarkedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didBookmark = snapshot?.exists else { return }
            completion(didBookmark)
        }
    }
    
    static func getAllLikesFor(post: Post, completion: @escaping([String]) -> Void) {
        COLLECTION_POSTS.document(post.postId).collection("posts-likes").getDocuments { snapshot, _ in
            guard let uid = snapshot?.documents else { return }
            let docIDs = uid.map({ $0.documentID })
            completion(docIDs)
        }
    }
    
    
    
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query =  COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid as Any)
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            let docIDs = documents.map({ $0.documentID })
            
            //Use docIDs to update user feed structure
            docIDs.forEach { id in
                if didFollow {
                    COLLECTION_USERS.document(uid).collection("user-home-feed").document(id).setData(["timestamp": Timestamp(date: Date())])
                } else {
                    COLLECTION_USERS.document(uid).collection("user-home-feed").document(id).delete()
                }
                
            }
        }
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
    
    //MARK: - Fetch with pagination
    
    static func fetchUserFeedPosts(previousQuery: Query?, completion: @escaping([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()

        let first = COLLECTION_POSTS.order(by: "timestamp").limit(to: 10)
        
        first.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            guard let lastSnapshot = snapshot.documents.last else {
                //the collection is empty
                return
            }

            posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            // Construct a new query starting after this document,
                // retrieving the next 25 cities.
            completion(posts)
            COLLECTION_POSTS.order(by: "timestamp").start(afterDocument: lastSnapshot)
            
          
            //print(next)
        }
    }
    
    /*
     static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
         guard let uid = Auth.auth().currentUser?.uid else { return }
         var posts = [Post]()
         
         COLLECTION_USERS.document(uid).collection("user-home-feed").getDocuments { snapshot, error in
             snapshot?.documents.forEach({ document in
                 fetchPost(withPostId: document.documentID) { post in
                     posts.append(post)
                     
                     posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                     
                     completion(posts)
                 }
             })
         }
     }
     */
}
