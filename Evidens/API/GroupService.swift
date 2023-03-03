//
//  GroupService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/11/22.
//

import UIKit
import FirebaseAuth
import Firebase

struct GroupService {
    
    static func uploadGroup(group: Group, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let groupRef = COLLECTION_GROUPS.document(group.groupId)
        
        let data = ["name": group.name,
                    "ownerUid": uid,
                    "id": group.groupId,
                    "description": group.description,
                    "visibility": group.visibility.rawValue,
                    "categories": group.categories,
                    "permissions": group.permissions.rawValue,
                    "bannerUrl": group.bannerUrl as Any,
                    "timestamp": Timestamp(date: Date()),
                    "profileUrl": group.profileUrl as Any
        ]
        
        groupRef.setData(data, completion: completion)
        
        DatabaseManager.shared.uploadNewGroup(groupId: groupRef.documentID) { _ in }
    }
    
    static func fetchGroups(completion: @escaping([Group]) -> Void) {
        COLLECTION_GROUPS.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            var groups: [Group] = documents.compactMap({ Group(groupId: $0.documentID, dictionary: $0.data()) })
            groups.enumerated().forEach { index, group in
                DatabaseManager.shared.fetchNumberOfGroupUsers(groupId: group.groupId) { members in
                    groups[index].members = members
                    completion(groups)
                }
                
            }
        }
    }
    
    
    
    static func fetchUserGroups(withGroupIds groupIds: [String], completion: @escaping([Group]) -> Void) {
        // Check user RTD all the ID groups
        // Download group details from Firestore
        var userGroups = [Group]()
        
        groupIds.forEach { id in
            COLLECTION_GROUPS.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let group = documents.map({ Group(groupId: $0.documentID, dictionary: $0.data()) })
                
                userGroups.append(contentsOf: group)
                
                userGroups.enumerated().forEach { index, group in
                    DatabaseManager.shared.fetchNumberOfGroupUsers(groupId: group.groupId) { members in
                        userGroups[index].members = members
                        completion(userGroups)
                    }
                }
            }
        }
    }
    
    /*
    static func fetchTopGroupsForTopic(topic: String, completion: @escaping([Post]) -> Void) {
        var count = 0
        let query = COLLECTION_GROUPS.whereField("professions", arrayContains: topic).limit(to: 3)
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
     */
    
    

    static func updateGroup(from group: Group, to newGroup: Group, completion: @escaping(Group) -> Void) {
        // Check what group values have changed
        var updatedGroupData = [String: Any]()
        
        let bannerUrl = (group.bannerUrl! == newGroup.bannerUrl!) ? "" : newGroup.bannerUrl
        let profileUrl = (group.profileUrl! == newGroup.profileUrl!) ? "" : newGroup.profileUrl
        let name = (group.name == newGroup.name) ? nil : newGroup.name
        let description = (group.description == newGroup.description) ? nil : newGroup.description
        let visibility = (group.visibility == newGroup.visibility) ? nil : newGroup.visibility.rawValue
        let permissions = (group.permissions == newGroup.permissions) ? nil : newGroup.permissions.rawValue
        let categories = (group.categories == newGroup.categories) ? nil : newGroup.categories
        
        if bannerUrl != "" { updatedGroupData["bannerUrl"] = bannerUrl }
        if profileUrl != "" { updatedGroupData["profileUrl"] = profileUrl }
        if let name = name { updatedGroupData["name"] = name }
        if let description = description { updatedGroupData["description"] = description }
        if let visibility = visibility { updatedGroupData["visibility"] = visibility }
        if let permissions = permissions { updatedGroupData["permissions"] = permissions }
        if let categories = categories { updatedGroupData["categories"] = categories }
        
        if updatedGroupData.isEmpty {
            completion(group)
            return
        }
        
        COLLECTION_GROUPS.document(group.groupId).updateData(updatedGroupData) { error in
            if error != nil { return }
            COLLECTION_GROUPS.document(group.groupId).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                let group = Group(groupId: group.groupId, dictionary: dictionary)
                completion(group)
            }
        }
    }
    
    static func uploadGroupPost(groupId: String, post: String, professions: [Profession], type: Post.PostType, privacy: Post.PrivacyOptions, groupPermission: Group.Permissions, postImageUrl: [String]?, completion: @escaping(FirestoreCompletion)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postId = COLLECTION_GROUPS.document(groupId).collection("posts").document().documentID
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "ownerUid": uid,
                    "comments": 0,
                    "shares": 0,
                    "professions": professions.map({ $0.profession }),
                    "groupId": groupId,
                    "type": type.rawValue,
                    "privacy": privacy.rawValue,
                    "bookmarks": 0,
                    "postImageUrl": postImageUrl as Any] as [String : Any]
        
        
        COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).setData(data, completion: completion)
        DatabaseManager.shared.uploadRecentPostToGroup(withGroupId: groupId, withPostId: postId, withPermission: groupPermission) { uploaded in
            print("post group uploaded")
        }
    }
    
    static func deleteGroupPost(groupId: String, postId: String, completion: @escaping(FirestoreCompletion)) {
        COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).delete(completion: completion)
    }
    
    static func deleteGroupCase(groupId: String, caseId: String, completion: @escaping(FirestoreCompletion)) {
        COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).delete(completion: completion)
    }
    
    static func uploadGroupCase(groupId: String, permissions: Group.Permissions, caseTitle: String, caseDescription: String, caseImageUrl: [String]?, specialities: [String], details: [String], stage: Case.CaseStage, diagnosis: String?, type: Case.CaseType, professions: [Profession], completion: @escaping(Error?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let caseId = COLLECTION_GROUPS.document(groupId).collection("cases").document().documentID
        
        let data = ["title": caseTitle,
                    "description": caseDescription,
                    "specialities": specialities,
                    "details": details,
                    "updates": "",
                    "likes": 0,
                    "stage": stage.caseStage,
                    "professions": professions.map({ $0.profession }),
                    "comments": 0,
                    "bookmarks": 0,
                    "views": 0,
                    "groupId": groupId,
                    "diagnosis": diagnosis as Any,
                    "ownerUid": uid,
                    "privacy": Case.Privacy.group.rawValue,
                    "timestamp": Timestamp(date: Date()),
                    "type": type.rawValue,
                    "caseImageUrl": caseImageUrl as Any]
        
        COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).setData(data, completion: completion)
        DatabaseManager.shared.uploadRecentCaseToGroup(withGroupId: groupId, withCaseId: caseId, withPermission: permissions) { uploaded in
            print("case group uploaded")
        }  
    }
    
    static func likeGroupPost(groupId: String, post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        //Add a new like to the post
        //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).updateData(["likes" : post.likes + 1])
        
        //Update posts likes collection to track likes for a particular post
        COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-likes").document(uid).setData([:]) { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-group-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func likeGroupCase(groupId: String, clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        //Add a new like to the post
        //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).updateData(["likes" : post.likes + 1])
        
        //Update posts likes collection to track likes for a particular post
        COLLECTION_GROUPS.document(groupId).collection("cases").document(clinicalCase.caseId).collection("case-likes").document(uid).setData([:]) { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-group-likes").document(clinicalCase.caseId).setData([:], completion: completion)
        }
    }
    
    static func unlikeGroupCase(groupId: String, clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        //Add a new like to the post
        //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).updateData(["likes" : post.likes + 1])
        
        //Update posts likes collection to track likes for a particular post
        COLLECTION_GROUPS.document(groupId).collection("cases").document(clinicalCase.caseId).collection("case-likes").document(uid).delete() { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-group-likes").document(clinicalCase.caseId).delete(completion: completion)
        }
    }
    
    static func unlikeGroupPost(groupId: String, post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        guard post.likes > 0 else { return }
        
        //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).updateData(["likes" : post.likes - 1])

        COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-likes").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-group-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func bookmarkGroupCase(groupId: String, clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_GROUPS.document(groupId).collection("cases").document(clinicalCase.caseId).collection("case-bookmarks").document(uid).setData([:]) { _ in
            COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).setData(["timestamp": Timestamp(date: Date()), "groupId": groupId], completion: completion)
            
        }
    }
    
    static func bookmarkGroupPost(groupId: String, post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-bookmarks").document(uid).setData([:]) { _ in
            COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).setData(["timestamp": Timestamp(date: Date()), "groupId": groupId], completion: completion)
            
        }
    }
    
    static func unbookmarkGroupPost(groupId: String, post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //guard post.numberOfBookmarks > 0 else { return }
        
        //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).updateData(["likes" : post.likes - 1])
        
        COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).collection("posts-bookmarks").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-posts-bookmarks").document(post.postId).delete(completion: completion)
        }
    }
    
    static func unbookmarkGroupCase(groupId: String, clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //guard clinicalCase.numberOfBookmarks > 0 else { return }
        
        //COLLECTION_GROUPS.document(groupId).collection("posts").document(post.postId).updateData(["likes" : post.likes - 1])
        
        COLLECTION_GROUPS.document(groupId).collection("cases").document(clinicalCase.caseId).collection("case-bookmarks").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).delete(completion: completion)
        }
    }
    
    
    
    static func fetchLikesForGroupPost(groupId: String, postId: String, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        let likesRef = COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).collection("posts-likes").count
        likesRef.getAggregation(source: .server) { snaphsot, _ in
            //guard let snaphsot = snaphsot else { return }
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
    
    static func fetchLikesForGroupCase(groupId: String, postId: String, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        let likesRef = COLLECTION_GROUPS.document(groupId).collection("cases").document(postId).collection("case-likes").count
        likesRef.getAggregation(source: .server) { snaphsot, _ in
            //guard let snaphsot = snaphsot else { return }
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
}


