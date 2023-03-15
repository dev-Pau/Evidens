//
//  SearchService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/23.
//

import UIKit
import Firebase

struct SearchService {
    static func fetchContentWithTopicSelected(topic: String, category: Search.Topics, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if lastSnapshot == nil {
            switch category {
            case .people:
                let firstGroupToFetch = COLLECTION_USERS.whereField("uid", isNotEqualTo: uid).whereField("profession", isEqualTo: topic).limit(to: 25)
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
            case .posts:
                let firstGroupToFetch = COLLECTION_POSTS.whereField("professions", arrayContains: topic).limit(to: 10)
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
            case .cases:
                let firstGroupToFetch = COLLECTION_CASES.whereField("professions", arrayContains: topic).limit(to: 10)
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
            case .groups:
                #warning("falta posar professions a group")
                let firstGroupToFetch = COLLECTION_GROUPS.whereField("professions", arrayContains: topic).limit(to: 10)
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
            case .jobs:
                let firstGroupToFetch = COLLECTION_GROUPS.whereField("profession", isEqualTo: topic).limit(to: 10)
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
            }
            
        } else {
            switch category {
            case .people:
                let firstGroupToFetch = COLLECTION_USERS.whereField("profession", isEqualTo: topic).start(afterDocument: lastSnapshot!).limit(to: 25)
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
            case .posts:
                let firstGroupToFetch = COLLECTION_POSTS.whereField("professions", arrayContains: topic).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .cases:
                let firstGroupToFetch = COLLECTION_CASES.whereField("professions", arrayContains: topic).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .groups:
                #warning("falta posar professions a group")
                let firstGroupToFetch = COLLECTION_GROUPS.whereField("professions", arrayContains: topic).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .jobs:
                let firstGroupToFetch = COLLECTION_GROUPS.whereField("profession", isEqualTo: topic).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            }
        }
    }
}
