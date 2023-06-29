//
//  PostService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/21.
//

import UIKit
import Firebase
import FirebaseAuth

struct PostService {

    static func uploadPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        var data = ["post": post.postText,
                    "timestamp": Timestamp(date: Date()),
                    "ownerUid": post.ownerUid,
                    "professions": post.professions.map { $0.profession },
                    "type": post.type.rawValue,
                    "privacy": post.privacyOptions.rawValue] as [String : Any]

        if !post.postImageUrl.isEmpty {
            data["postImageUrl"] = post.postImageUrl
        }
               
        let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)

        DatabaseManager.shared.uploadRecentPost(withUid: docRef.documentID, withDate: Date()) { _ in }
    }
    
    static func editGroupPost(withGroupId groupId: String, withPostUid postUid: String, withNewText text: String, completion: @escaping(Bool) -> Void) {
        let postData = ["post": text,
                        "edited": true] as [String : Any]
        
        COLLECTION_GROUPS.document(groupId).collection("posts").document(postUid).setData(postData, merge: true) { error in
            if let err = error {
                print("Error writing document: \(err)")
                completion(false)
                return
            } else {
                completion(true)
                return
            }
        }
    }
    
    static func editPost(withPostUid postUid: String, withNewText text: String, completion: @escaping(Bool) -> Void) {
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
        let query = COLLECTION_POSTS.whereField("ownerUid", isNotEqualTo: user.uid!).whereField("professions", arrayContainsAny: [user.profession!]).limit(to: 3)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            //Mapping that creates an array for each post
            var posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            posts.enumerated().forEach { index, post in
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
            }
        }
    }
    
    static func deletePost(withPostUid uid: String, completion: @escaping(Bool) -> Void) {
        
    }
    
    static func fetchLikesForPost(postId: String, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likesRef = COLLECTION_POSTS.document(postId).collection("post-likes").count
        likesRef.getAggregation(source: .server) { snaphsot, _ in
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
    
    static func fetchCommentsForPost(postId: String, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likesRef = COLLECTION_POSTS.document(postId).collection("comments").count
        likesRef.getAggregation(source: .server) { snaphsot, _ in
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
    
    static func fetchHomeDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if lastSnapshot == nil {
            // Fetch first group of posts
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).limit(to: 10)
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
            // Append new posts 
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
                
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
    
    static func fetchSearchDocumentsForProfession(user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
         
         if lastSnapshot == nil {
             // Fetch first group of posts
             let firstGroupToFetch = COLLECTION_POSTS.whereField("professions", arrayContains: user.profession!).limit(to: 10)
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
             // Append new posts
             let nextGroupToFetch = COLLECTION_POSTS.whereField("professions", arrayContains: user.profession!).start(afterDocument: lastSnapshot!).limit(to: 10)
                 
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
    
    
    static func fetchHomePosts(snapshot: QuerySnapshot, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()

        snapshot.documents.forEach { document in
            let bookmarkPostType = PostSource(dictionary: document.data())
            if let groupId = bookmarkPostType.groupId {
                fetchGroupPost(withGroupId: groupId, withPostId: document.documentID) { post in
                    posts.append(post)
                    if snapshot.documents.count == posts.count {
                        posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        completion(posts)
                    }
                }
            } else {
                fetchPost(withPostId: document.documentID) { post in
                    //getPostValuesFor(post: post) { newPost in
                    posts.append(post)
                    if snapshot.documents.count == posts.count {
                        posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        completion(posts)
                    }
                }
            }
        }
    }
    
    
    static func checkIfUserHasNewerPostsToDisplay(snapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let snapshot = snapshot else { return }
        //COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: true).limit(to: 10)
        let newQuery = COLLECTION_USERS.document(uid).collection("user-home-feed").order(by: "timestamp", descending: false).start(afterDocument: snapshot).limit(to: 10)

        newQuery.getDocuments { snapshot, _ in
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
    
    static func fetchRecentPosts(withPostId postId: [String], completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        postId.forEach { id in
            fetchPost(withPostId: id) { post in
                posts.append(post)
                if posts.count == postId.count {
                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(posts)
                }
            }
        }
    }
    
    static func fetchPosts(withPostIds postIds: [String], completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        postIds.forEach { postId in
            fetchPost(withPostId: postId) { post in
                //getPostValuesFor(post: post) { postWithValues in
                    posts.append(post)
                    if posts.count == postIds.count {
                        posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        completion(posts)
                    }
                }
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postId: snapshot.documentID, dictionary: data)
            getPostValuesFor(post: post) { postWithValues in
                completion(postWithValues)
            }
        }
    }
    
    static func fetchGroupPost(withGroupId groupId: String, withPostId postId: String, completion: @escaping(Post) -> Void) {
        COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postId: snapshot.documentID, dictionary: data)
            getGroupPostValuesFor(post: post) { fetchedPost in
                completion(fetchedPost)
            }
            
            /*
            GroupService.fetchLikesForGroupPost(groupId: groupId, postId: postId) { likes in
                post.likes = likes
                CommentService.fetchNumberOfCommentsForPost(post: post, type: .group) { comments in
                    post.numberOfComments = comments
                    #warning("kek")
                    completion(post)
                }
            }
             */
        }
    }
    
    static func fetchGroupPosts(withGroupId groupId: String, withPostIds postIds: [String], completion: @escaping([Post]) -> Void) {
        var groupPosts = [Post]()
        postIds.forEach { postId in
            COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                guard let data = snapshot.data() else { return }
                let post = Post(postId: snapshot.documentID, dictionary: data)
                getGroupPostValuesFor(post: post) { fetchedPost in
                    groupPosts.append(fetchedPost)
                    if groupPosts.count == postIds.count {
                        completion(groupPosts)
                    }
                }
            }
        }
    }
    
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
    
    static func fetchTopPostsForTopic(topic: String, completion: @escaping([Post]) -> Void) {
        var count = 0
        let query = COLLECTION_POSTS.whereField("professions", arrayContains: topic).limit(to: 3)
        query.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var posts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            posts.enumerated().forEach { index, post in
                self.checkIfUserLikedPost(post: post) { like in
                    self.checkIfUserBookmarkedPost(post: post) { bookmark in
                        fetchLikesForPost(postId: post.postId) { likes in
                            posts[index].likes = likes
                            fetchCommentsForPost(postId: post.postId) { comments in
                                posts[index].numberOfComments = comments
                                posts[index].didLike = like
                                posts[index].didBookmark = bookmark
                                count += 1
                                if count == posts.count {
                                    completion(posts)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getPostValuesFor(post: Post, completion: @escaping(Post) -> Void) {
        var auxPost = post
        checkIfUserLikedPost(post: post) { like in
            checkIfUserBookmarkedPost(post: post) { bookmark in
                fetchLikesForPost(postId: post.postId) { likes in
                    auxPost.likes = likes
                    fetchCommentsForPost(postId: post.postId) { comments in
                        auxPost.numberOfComments = comments
                        auxPost.didLike = like
                        auxPost.didBookmark = bookmark
                        completion(auxPost)
                    }
                }
            }
        }
    }
    
    static func getPostValuesFor(posts: [Post], completion: @escaping([Post]) -> Void) {
        var auxPosts = posts
        posts.enumerated().forEach { index, post in
            self.checkIfUserLikedPost(post: post) { like in
                self.checkIfUserBookmarkedPost(post: post) { bookmark in
                    fetchLikesForPost(postId: post.postId) { likes in
                        fetchCommentsForPost(postId: post.postId) { comments in
                            auxPosts[index].didLike = like
                            auxPosts[index].didBookmark = bookmark
                            auxPosts[index].likes = likes
                            auxPosts[index].numberOfComments = comments
                            
                            if auxPosts.count == posts.count {
                                completion(auxPosts)
                            }
                        }
                    }
                }
            }
        }
    }
    
    


    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        //Add a new like to the post
        //Update posts likes collection to track likes for a particular post
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData(likeData) { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).setData(likeData, completion: completion)
        }
    }
    
    static func bookmarkPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let bookmarkData = ["timestamp": Timestamp(date: Date())]
        //Update post bookmark collection to track bookmarks for a particular post
        COLLECTION_POSTS.document(post.postId).collection("posts-bookmarks").document(uid).setData(bookmarkData) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).setData(bookmarkData, completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        guard post.likes > 0 else { return }
        
        //COLLECTION_POSTS.document(post.postId).updateData(["likes" : post.likes - 1])

        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func unbookmarkPost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //guard post.numberOfBookmarks > 0 else { return }
        
        //COLLECTION_POSTS.document(post.postId).updateData(["bookmarks" : post.numberOfBookmarks - 1])
        
        COLLECTION_POSTS.document(post.postId).collection("posts-bookmarks").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let _ = post.groupId {
            COLLECTION_USERS.document(uid).collection("user-group-likes").document(post.postId).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        } else {
            COLLECTION_USERS.document(uid).collection("user-home-likes").document(post.postId).getDocument { (snapshot, _) in
                
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        }

    }
    
    static func checkIfUserBookmarkedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).getDocument { (snapshot, _) in
            
            //If the snapshot (document) exists, means current user did like the post
            guard let didBookmark = snapshot?.exists else { return }
            completion(didBookmark)
        }
    }
    
    static func getAllLikesFor(post: Post, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            if let groupId = post.groupId {
                COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("post-likes").limit(to: 30).getDocuments { snapshot, _ in
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
                COLLECTION_POSTS.document(post.postId).collection("post-likes").limit(to: 30).getDocuments { snapshot, _ in
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
            if let groupId = post.groupId {
                COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("post-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, _ in
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
                COLLECTION_POSTS.document(post.postId).collection("post-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, _ in
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
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    static func fetchBookmarkedPosts(snapshot: QuerySnapshot, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()

        snapshot.documents.forEach({ document in
            let data = document.data()
            if let value = data["groupId"] as? String {
                fetchGroupPost(withGroupId: value, withPostId: document.documentID) { post in

                    posts.append(post)
                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(posts)
                }
            } else {
                
                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(posts)
                }
            }
        })
    }
}
