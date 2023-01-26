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
    
    static func uploadGroupPost(groupId: String, post: String, type: Post.PostType, privacy: Post.PrivacyOptions, groupPermission: Group.Permissions, postImageUrl: [String]?, completion: @escaping(FirestoreCompletion)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postId = COLLECTION_GROUPS.document(groupId).collection("posts").document().documentID
        
        let data = ["post": post,
                    "timestamp": Timestamp(date: Date()),
                    "likes": 0,
                    "ownerUid": uid,
                    "comments": 0,
                    "shares": 0,
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
    
    static func uploadGroupCase(groupId: String, permissions: Group.Permissions, caseTitle: String, caseDescription: String, caseImageUrl: [String]?, specialities: [String], details: [String], stage: Case.CaseStage, diagnosis: String?, type: Case.CaseType, completion: @escaping(Error?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let caseId = COLLECTION_GROUPS.document(groupId).collection("cases").document().documentID
        
        let data = ["title": caseTitle,
                    "description": caseDescription,
                    "specialities": specialities,
                    "details": details,
                    "updates": "",
                    "likes": 0,
                    "stage": stage.caseStage,
                    "comments": 0,
                    "bookmarks": 0,
                    "views": 0,
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
    

}
