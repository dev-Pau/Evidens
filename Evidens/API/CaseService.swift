//
//  CaseService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Firebase
import FirebaseAuth
import AlgoliaSearchClient

struct CaseService {
    
    static func uploadCase(privacy: Case.Privacy, caseTitle: String, caseDescription: String, caseImageUrl: [String]?, specialities: [String], details: [String], stage: Case.CaseStage, diagnosis: String?, type: Case.CaseType, user: User, professions: [Profession], completion: @escaping(Error?) -> Void) {
        
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
                    "professions": professions.map({ $0.profession }),
                    "diagnosis": diagnosis as Any,
                    "ownerUid": user.uid as Any,
                    "privacy": privacy.rawValue,
                    "timestamp": Timestamp(date: Date()),
                    "type": type.rawValue,
                    "caseImageUrl": caseImageUrl as Any
        ]
        
        let caseRef = COLLECTION_CASES.addDocument(data: data, completion: completion)
        
        if privacy == .visible {
            DatabaseManager.shared.uploadRecentCase(withUid: caseRef.documentID) { uploaded in
                print("Case uploaded to recents")
            }
        }
    }
    
    static func fetchCases(completion: @escaping([Case]) -> Void) {
        COLLECTION_CASES.order(by: "timestamp", descending: true).limit(to: 10).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            completion(cases)
        }
    }
    
    
    static func fetchClinicalCases(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {

        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_CASES.start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchUserVisibleCases(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).whereField("privacy", isEqualTo: 0).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).whereField("privacy", isEqualTo: 0).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    
    static func fetchLastUploadedClinicalCases(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {

        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_CASES.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchCasesWithProfession(lastSnapshot: QueryDocumentSnapshot?, profession: String, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("professions", arrayContains: profession).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_CASES.whereField("professions", isEqualTo: profession).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    /*
     static func fetchCasesWithDetailsFilter(fieldToQuery: String, valueToQuery: String) {
         COLLECTION_CASES.order(by: "timestamp", descending: true).whereField(fieldToQuery, arrayContains: valueToQuery).getDocuments { snapshot, error in
             guard let documents = snapshot?.documents else { return }
             let cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
             cases.forEach { clinicalCase in
                 print(clinicalCase.caseDescription)
             }
         }
     }
     */
     
    
    static func uploadCaseUpdate(withCaseId caseId: String, withUpdate text: String, withGroupId groupId: String? = nil, completion: @escaping(Bool) -> Void) {
        if let groupId = groupId {
            COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).updateData(["updates": FieldValue.arrayUnion([text])]) { error in
                if let _ = error {
                    print("error uploading diagnosis")
                    completion(false)
                }
                completion(true)
            }
        } else {
            COLLECTION_CASES.document(caseId).updateData(["updates": FieldValue.arrayUnion([text])]) { error in
                if let _ = error {
                    print("error uploading")
                    completion(false)
                }
                completion(true)
            }
        }
    }
    
    static func uploadCaseStage(withCaseId caseId: String, withGroupId groupId: String? = nil, completion: @escaping(Bool) -> Void) {
        if let groupId = groupId {
            COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).updateData(["stage": Case.CaseStage.resolved.rawValue]) { error in
                if let _ = error {
                    print("error uploading diagnosis")
                    completion(false)
                }
                completion(true)
            }
        } else {
            COLLECTION_CASES.document(caseId).updateData(["stage": Case.CaseStage.resolved.rawValue]) { error in
                if let _ = error {
                    print("error uploading diagnosis")
                    completion(false)
                }
                completion(true)
            }
        }
    }
    
    static func uploadCaseDiagnosis(withCaseId caseId: String, withDiagnosis text: String, withGroupId groupId: String? = nil, completion: @escaping(Bool) -> Void) {
        if let groupId = groupId {
            COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).updateData(["diagnosis": text, "stage": Case.CaseStage.resolved.rawValue]) { error in
                if let _ = error {
                    print("error uploading diagnosis")
                    completion(false)
                }
                completion(true)
            }
        } else {
            COLLECTION_CASES.document(caseId).updateData(["diagnosis": text, "stage": Case.CaseStage.resolved.rawValue]) { error in
                if let _ = error {
                    print("error uploading diagnosis")
                    completion(false)
                }
                completion(true)
            }
        }
        
    }
    
    
    static func fetchRecentCases(withCaseId caseId: [String], completion: @escaping([Case]) -> Void) {
        var cases = [Case]()
        
        caseId.forEach { id in
            fetchCase(withCaseId: id) { post in
                cases.append(post)
                
                cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })

                completion(cases)
                
            }
        }
    }
    
    static func fetchCases(forUser uid: String, completion: @escaping([Case]) -> Void) {
        //Fetch posts by filtering according to timestamp & user uid
        let query =  COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
        
            var cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            
            cases.enumerated().forEach { index, clinicalCase in
                if clinicalCase.privacyOptions == .nonVisible {
                    cases.remove(at: index)
                }
            }
            
            //Order posts by timestamp
            cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            
            completion(cases)
        }
    }
    
    static func fetchVisibleCases(forUser uid: String, completion: @escaping([Case]) -> Void) {
        //Fetch posts by filtering according to timestamp & user uid
        let query =  COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).whereField("privacy", isEqualTo: 0)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
        
            var cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            
            //Order posts by timestamp
            cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            
            completion(cases)
        }
    }
    
    static func fetchTopCases(completion: @escaping([Case]) -> Void) {
        //Fetch posts by filtering according to timestamp
        let query = COLLECTION_CASES.order(by: "timestamp", descending: true).limit(to: 3)
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            //Mapping that creates an array for each post
            let cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            completion(cases)
        }
    }
    
    static func fetchCase(withCaseId caseId: String, completion: @escaping(Case) -> Void) {
        COLLECTION_CASES.document(caseId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let clinicalCase = Case(caseId: snapshot.documentID, dictionary: data)
            completion(clinicalCase)
        }
    }
    
    static func fetchGroupCase(withGroupId groupId: String, withCaseId caseId: String, completion: @escaping(Case) -> Void) {
        
        COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            var clinicalCase = Case(caseId: snapshot.documentID, dictionary: data)
            GroupService.fetchLikesForGroupCase(groupId: groupId, postId: caseId) { likes in
                clinicalCase.likes = likes
                CommentService.fetchNumberOfCommentsForCase(clinicalCase: clinicalCase, type: .group) { comments in
                    clinicalCase.numberOfComments = comments
                    completion(clinicalCase)
                }
            }
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        if let _ = clinicalCase.groupId {
            COLLECTION_USERS.document(uid).collection("user-group-likes").document(clinicalCase.caseId).getDocument { (snapshot, _) in
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        } else {
            COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).getDocument { (snapshot, _) in
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            }
        }
    }

    static func bookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_CASES.document(clinicalCase.caseId).updateData(["bookmarks" : clinicalCase.numberOfBookmarks + 1])
        
        //Update post bookmark collection to track bookmarks for a particular post
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-bookmarks").document(uid).setData([:]) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).setData(["timestamp": Timestamp(date: Date())], completion: completion)
        }
    }
    
    static func unbookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //guard clinicalCase.numberOfBookmarks > 0 else { return }
        
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
        if let groupId = clinicalCase.groupId {
            COLLECTION_GROUPS.document(groupId).collection("cases").document(clinicalCase.caseId).collection("case-likes").getDocuments { snapshot, _ in
                guard let uid = snapshot?.documents else { return }
                let docIDs = uid.map({ $0.documentID })
                completion(docIDs)
            }
        } else {
            COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").getDocuments { snapshot, _ in
                guard let uid = snapshot?.documents else { return }
                let docIDs = uid.map({ $0.documentID })
                completion(docIDs)
            }
        }
    }
    
    static func fetchBookmarkedCaseDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-case-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-case-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchBookmarkedCases(snapshot: QuerySnapshot, completion: @escaping([Case]) -> Void) {
        var cases = [Case]()
        snapshot.documents.forEach({ document in
            fetchCase(withCaseId: document.documentID) { clinicalCase in
                cases.append(clinicalCase)
                cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                completion(cases)
            }
        })
    }
}

