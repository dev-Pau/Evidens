//
//  CaseService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Firebase

struct CaseService {
    
    static func uploadCase(caseTitle: String, caseDescription: String, caseImageUrl: [String]?, specialities: [String], details: [String], stage: Case.CaseStage, diagnosis: String?, type: Case.CaseType, user: User, completion: @escaping(Error?) -> Void) {
        
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
                    "ownerUid": user.uid as Any,
                    "ownerCategory": user.category.rawValue,
                    "timestamp": Timestamp(date: Date()),
                    "type": type.rawValue,
                    "ownerFirstName": user.firstName as Any,
                    "ownerProfession": user.profession as Any,
                    "ownerSpeciality": user.speciality as Any,
                    "ownerLastName": user.lastName as Any,
                    "ownerImageUrl": user.profileImageUrl as Any,
                    "caseImageUrl": caseImageUrl as Any
        ]
        
        COLLECTION_CASES.addDocument(data: data, completion: completion)
    }
    
    static func fetchCases(completion: @escaping([Case]) -> Void) {
        COLLECTION_CASES.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            completion(cases)
        }
    }
    
    static func likeCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Add a new like to the post
        COLLECTION_CASES.document(clinicalCase.caseId).updateData(["likes": clinicalCase.likes + 1])
        
        //Update posts likes collection to track likes for a particular post
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").document(uid).setData([:]) { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).setData([:], completion: completion)
        }
    }
    
    static func unlikeCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard clinicalCase.likes > 0 else { return }
        
        COLLECTION_CASES.document(clinicalCase.caseId).updateData(["likes" : clinicalCase.likes - 1])

        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedCase(clinicalCase: Case, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).getDocument { (snapshot, _) in
            //If the snapshot (document) exists, means current user did like the post
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }

    static func bookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_CASES.document(clinicalCase.caseId).updateData(["bookmarks" : clinicalCase.numberOfBookmarks + 1])
        
        //Update post bookmark collection to track bookmarks for a particular post
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-bookmarks").document(uid).setData([:]) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).setData([:], completion: completion)
        }
    }
    
    static func unbookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard clinicalCase.numberOfBookmarks > 0 else { return }
        
        COLLECTION_CASES.document(clinicalCase.caseId).updateData(["bookmarks" : clinicalCase.numberOfBookmarks - 1])
        
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-bookmarks").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).delete(completion: completion)
        }
    }
    
    static func checkIfUserBookmarkedCase(clinicalCase: Case, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).getDocument { (snapshot, _) in
            //If the snapshot (document) exists, means current user did like the post
            guard let didBookmark = snapshot?.exists else { return }
            completion(didBookmark)
        }
    }
    
    static func getAllLikesFor(clinicalCase: Case, completion: @escaping([String]) -> Void) {
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").getDocuments { snapshot, _ in
            guard let uid = snapshot?.documents else { return }
            let docIDs = uid.map({ $0.documentID })
            completion(docIDs)
        }
    }
}

