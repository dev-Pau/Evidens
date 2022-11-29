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
        
        let groupRef = COLLECTION_GROUPS.document()
        
        //let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        let data = ["name": group.name,
                    "ownerUid": uid,
                    "id": groupRef.documentID,
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
            guard let documents = snapshot?.documents else { return }
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
            }
        }
    }
}
