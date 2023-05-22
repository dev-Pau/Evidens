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
        
        let trimmedText = group.name.trimmingCharacters(in: .whitespaces)
        let arrayTextToSearch = trimmedText.split(separator: " ").map({ $0.lowercased() }).map({ $0.capitalized })
        
        let data = ["name": group.name,
                    "ownerUid": uid,
                    "id": group.groupId,
                    "searchFor": arrayTextToSearch,
                    "description": group.description,
                    "professions": group.professions,
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
        COLLECTION_GROUPS.limit(to: 30).getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }

            var groups: [Group] = snapshot.documents.compactMap({ Group(groupId: $0.documentID, dictionary: $0.data()) })
            groups.enumerated().forEach { index, group in
                DatabaseManager.shared.fetchNumberOfGroupUsers(groupId: group.groupId) { members in
                    groups[index].members = members
                    completion(groups)
                }
                
            }
        }
    }
    
    static func fetchTopGroupsForTopic(topic: String, completion: @escaping([Group]) -> Void) {
        let query = COLLECTION_GROUPS.whereField("professions", arrayContains: topic).limit(to: 3)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var groups = snapshot.documents.map({ Group(groupId: $0.documentID, dictionary: $0.data()) })
            var aggrCount = 0
            groups.enumerated().forEach { index, group in
                DatabaseManager.shared.fetchNumberOfGroupUsers(groupId: group.groupId) { members in
                    groups[index].members = members
                    aggrCount += 1
                    if aggrCount == groups.count {
                        completion(groups)
                    }
                }
            }
        }
    }
    
    static func fetchGroupsWithText(_ text: [String], lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            COLLECTION_GROUPS.whereField("searchFor", arrayContainsAny: text).limit(to: 10).getDocuments { snapshot, _ in
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
            COLLECTION_GROUPS.whereField("searchFor", arrayContainsAny: text).start(afterDocument: lastSnapshot!).limit(to: 10).getDocuments { snapshot, _ in
                guard let snapshot = snapshot else {
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
    
    static func fetchGroups(withGroupIds groupIds: [String], completion: @escaping([Group]) -> Void) {
        var fetchedGroups = [Group]()
        groupIds.forEach { id in
            COLLECTION_GROUPS.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let group = documents.map({ Group(groupId: $0.documentID, dictionary: $0.data()) })
                fetchedGroups.append(contentsOf: group)
                if fetchedGroups.count == groupIds.count {
                    completion(fetchedGroups)
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
    
    static func uploadGroupPost(post: Post, withPermission permission: Group.Permissions, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let groupId = post.groupId else { return }
        
        let postId = COLLECTION_GROUPS.document(groupId).collection("posts").document().documentID
        
        var data = ["post": post.postText,
                    "timestamp": Timestamp(date: Date()),
                    "ownerUid": uid,
                    "professions": post.professions.map({ $0.profession }),
                    "groupId": groupId,
                    "type": post.type.rawValue,
                    "privacy": post.privacyOptions.rawValue] as [String : Any]
        
        if post.postImageUrl.count > 0 {
            data["postImageUrl"] = post.postImageUrl
        }

        
        COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).setData(data, completion: completion)
        DatabaseManager.shared.uploadRecentPostToGroup(withGroupId: groupId, withPostId: postId, withPermission: permission) { uploaded in
            print("post group uploaded")
        }
    }
    
    static func deleteGroupPost(groupId: String, postId: String, completion: @escaping(FirestoreCompletion)) {
        COLLECTION_GROUPS.document(groupId).collection("posts").document(postId).delete(completion: completion)
    }
    
    static func deleteGroupCase(groupId: String, caseId: String, completion: @escaping(FirestoreCompletion)) {
        COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).delete(completion: completion)
    }
    
    static func uploadGroupCase(groupId: String, permissions: Group.Permissions, caseTitle: String, caseDescription: String, caseImageUrl: [String]? = nil, specialities: [String], details: [String], stage: Case.CaseStage, diagnosis: String? = nil, type: Case.CaseType, professions: [String], completion: @escaping(Error?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let caseId = COLLECTION_GROUPS.document(groupId).collection("cases").document().documentID
        
        var data = ["title": caseTitle,
                    "description": caseDescription,
                    "specialities": specialities,
                    "details": details,
                    "groupId": groupId,
                    "stage": stage.caseStage,
                    "professions": professions,
                    "ownerUid": uid,
                    "privacy": Case.Privacy.group.rawValue,
                    "timestamp": Timestamp(date: Date()),
                    "type": type.rawValue] as [String : Any]
        
        if let diagnosis = diagnosis {
            data["diagnosis"] = diagnosis
        }
        if let caseImageUrl = caseImageUrl {
            data["caseImageUrl"] = caseImageUrl
        }
        
        
        COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).setData(data, completion: completion)
        DatabaseManager.shared.uploadRecentCaseToGroup(withGroupId: groupId, withCaseId: caseId, withPermission: permissions) { uploaded in
            print("case group uploaded")
        }
        
        /*
        let data = ["title": caseTitle,
                    "description": caseDescription,
                    "specialities": specialities,
                    "details": details,
                    "stage": stage.caseStage,
                    "professions": professions,
                    "groupId": groupId,
                    "diagnosis": diagnosis as Any,
                    "ownerUid": uid,
                    "privacy": Case.Privacy.group.rawValue,
                    "timestamp": Timestamp(date: Date()),
                    "type": type.rawValue,
                    "caseImageUrl": caseImageUrl as Any]
        
        /*
         guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
         var data = ["title": caseTitle,
                     "description": caseDescription,
                     "specialities": specialities,
                     "details": details,
                     "stage": stage.caseStage,
                     "professions": professions,
                     "ownerUid": uid,
                     "privacy": privacy.rawValue,
                     "timestamp": Timestamp(date: Date()),
                     "type": type.rawValue] as [String : Any]
         
         if let diagnosis = diagnosis {
             data["diagnosis"] = diagnosis
         }
         if let caseImageUrl = caseImageUrl {
             data["caseImageUrl"] = caseImageUrl
         }
*/
         let caseRef = COLLECTION_CASES.addDocument(data: data, completion: completion)
         
         
         if privacy == .visible {
             DatabaseManager.shared.uploadRecentCase(withUid: caseRef.documentID) { uploaded in
                 print("Case uploaded to recents")
             }
         }
     }
     
         */
        
        
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
    
    static func fetchLikesForGroupCase(groupId: String, caseId: String, completion: @escaping(Int) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //let likesRef = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        let likesRef = COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).collection("case-likes").count
        likesRef.getAggregation(source: .server) { snaphsot, _ in
            //guard let snaphsot = snaphsot else { return }
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
}


