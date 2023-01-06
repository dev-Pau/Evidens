//
//  GroupService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/11/22.
//

import UIKit
import Firebase

struct GroupService {
    
    static func uploadGroup(group: Group, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let groupRef = COLLECTION_GROUPS.document(group.groupId)
        
        let data = ["name": group.name,
                    "ownerUid": uid,
                    "id": group.groupId,
                    "description": group.description,
                    "members": 1,
                    "visibility": group.visibility.rawValue,
                    "categories": group.categories,
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
            
            let groups: [Group] = documents.compactMap({ Group(groupId: $0.documentID, dictionary: $0.data()) })
            completion(groups)
        }
    }
    
    static func fetchUserGroups(completion: @escaping([Group]) -> Void) {
        // Check user RTD all the ID groups
        // Download group details from Firestore
        var userGroups = [Group]()
        DatabaseManager.shared.fetchUserIdGroups { result in
            
            switch result {
            case .success(let groupIds):
                groupIds.forEach { id in
                    COLLECTION_GROUPS.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
                        guard let documents = snapshot?.documents else { return }
                        let group = documents.map({ Group(groupId: $0.documentID, dictionary: $0.data()) })
                        userGroups.append(contentsOf: group)
                        completion(userGroups)
                    }
                }
            case .failure(let error):
                print(error)
                completion([])
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
        let categories = (group.categories == newGroup.categories) ? nil : newGroup.categories
        
        if bannerUrl != "" { updatedGroupData["bannerUrl"] = bannerUrl }
        if profileUrl != "" { updatedGroupData["profileUrl"] = profileUrl }
        if let name = name { updatedGroupData["name"] = name }
        if let description = description { updatedGroupData["description"] = description }
        if let visibility = visibility { updatedGroupData["visibility"] = visibility }
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
}
