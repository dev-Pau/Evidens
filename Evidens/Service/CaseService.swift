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
    
    static func addCase(viewModel: ShareCaseViewModel, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let title = viewModel.title, let description = viewModel.description, let phase = viewModel.phase else {
            completion(.unknown)
            return
        }
        
        let timestamp = Timestamp()
        let specialities = viewModel.specialities
        let disciplines = viewModel.disciplines
        let items = viewModel.items
        let privacy = viewModel.privacy
        
        var clinicalCase = ["title": title,
                            "content": description,
                            "specialities": specialities.map { $0.rawValue },
                            "items": items.map { $0.rawValue },
                            "phase": phase.rawValue,
                            "disciplines": disciplines.map { $0.rawValue },
                            "uid": uid,
                            "privacy": privacy.rawValue,
                            "timestamp": timestamp] as [String : Any]
        
        if viewModel.hasHashtags {
            clinicalCase["hashtags"] = viewModel.hashtags
        }
        
        let caseRef = COLLECTION_CASES.document()
        
        if viewModel.hasImages {
            clinicalCase["kind"] = CaseKind.image.rawValue
            StorageManager.addImages(toCaseId: caseRef.documentID, viewModel.images) { result in
                switch result {
                case .success(let imageUrl):
                    clinicalCase["imageUrl"] = imageUrl
                    caseRef.setData(clinicalCase) { error in
                        if let _ = error {
                            completion(.unknown)
                        } else {
                            if let diagnosis = viewModel.diagnosis {
                                let caseId = caseRef.documentID
                                
                                let diagnosis: [String: Any] = ["content": diagnosis.content,
                                                                "kind": diagnosis.kind.rawValue,
                                                                "timestamp": timestamp]
                                
                                COLLECTION_CASES.document(caseId).collection("case-revisions").addDocument(data: diagnosis) { error in
                                    if let _ = error {
                                        completion(.unknown)
                                    } else {
                                        addRecent(forCaseId: caseId, privacy: privacy)
                                        completion(nil)
                                    }
                                }
                            } else {
                                addRecent(forCaseId: caseRef.documentID, privacy: privacy)
                                completion(nil)
                            }
                        }
                    }
                case .failure(_):
                    completion(.unknown)
                }
            }
        } else {
            clinicalCase["kind"] = CaseKind.text.rawValue
            caseRef.setData(clinicalCase) { error in
                if let _ = error {
                    completion(.unknown)
                } else {
                    if let diagnosis = viewModel.diagnosis {
                        let caseId = caseRef.documentID
                        
                        let diagnosis: [String: Any] = ["content": diagnosis.content,
                                                        "kind": diagnosis.kind.rawValue,
                                                        "timestamp": timestamp]

                        COLLECTION_CASES.document(caseId).collection("case-revisions").addDocument(data: diagnosis) { error in
                            if let _ = error {
                                completion(.unknown)
                            } else {
                                addRecent(forCaseId: caseId, privacy: privacy)
                                completion(nil)
                            }
                        }
                    } else {
                        addRecent(forCaseId: caseRef.documentID, privacy: privacy)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    static func addRecent(forCaseId id: String, privacy: CasePrivacy) {
        guard privacy == .regular else {
            return
        }
        DatabaseManager.shared.addRecentCase(withCaseId: id)
    }

    static func fetchCases(completion: @escaping([Case]) -> Void) {
        COLLECTION_CASES.order(by: "timestamp", descending: true).limit(to: 10).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            completion(cases)
        }
    }
    
    static func fetchCases(withCaseIds caseIds: [String], completion: @escaping([Case]) -> Void) {
        var cases = [Case]()
        caseIds.forEach { caseId in
            fetchCase(withCaseId: caseId) { clinicalCase in
                getCaseValuesFor(clinicalCase: clinicalCase) { caseWithValues in
                    cases.append(caseWithValues)
                    if cases.count == caseIds.count {
                        completion(cases)
                    }
                }
            }
        }
    }
    
    static func getCaseValuesFor(clinicalCase: Case, completion: @escaping(Case) -> Void) {
        var auxCase = clinicalCase
        checkIfUserLikedCase(clinicalCase: clinicalCase) { like in
            checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { bookmark in
                fetchLikesForCase(caseId: clinicalCase.caseId) { likes in
                    fetchCommentsForCase(caseId: clinicalCase.caseId) { comments in
                        auxCase.likes = likes
                        auxCase.numberOfComments = comments
                        auxCase.didBookmark = bookmark
                        auxCase.didLike = like
                        completion(auxCase)
                    }
                }
            }
        }
    }
    
    static func getCaseValuesFor(cases: [Case], completion: @escaping([Case]) -> Void) {
        var auxCases = cases
        cases.enumerated().forEach { index, clinicalCase in
            checkIfUserLikedCase(clinicalCase: clinicalCase) { like in
                checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { bookmark in
                    fetchLikesForCase(caseId: clinicalCase.caseId) { likes in
                        fetchCommentsForCase(caseId: clinicalCase.caseId) { comments in
                            auxCases[index].likes = likes
                            auxCases[index].numberOfComments = comments
                            auxCases[index].didBookmark = bookmark
                            auxCases[index].didLike = like
                            if auxCases.count == cases.count {
                                completion(auxCases)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func fetchCasesWithHashtag(_ hashtag: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("hashtags", arrayContains: hashtag).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    print("error")
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    print("is empty")
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                print("we found something")
                completion(.success(snapshot))
            }
        } else {
            // Append new posts
            let nextGroupToFetch = COLLECTION_CASES.whereField("hashtags", arrayContains: hashtag).start(afterDocument: lastSnapshot!).limit(to: 10)
                
            nextGroupToFetch.getDocuments { snapshot, error in
                if let error {
                    let nsError = error as NSError
                    let _ = FirestoreErrorCode(_nsError: nsError)
                    completion(.failure(.unknown))
                }
                
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    completion(.success(snapshot))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
    
    static func checkIfUserHasNewCasesToDisplay(category: Case.FilterCategories, snapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let snapshot = snapshot else { return }
        
        switch category {
        case .explore:
            return
        case .all:
            return
        case .recents:
            let query = COLLECTION_CASES.order(by: "timestamp", descending: false).start(afterDocument: snapshot).limit(to: 10)
            query.getDocuments { snapshot, _ in
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    print("empty")
                    completion(snapshot!)
                    return
                }
                
                guard snapshot.documents.last != nil else {
                    print("no")
                    completion(snapshot)
                    return
                }
                
                completion(snapshot)
            }
        case .solved:
            return
        case .unsolved:
            return
        case .you:
            return
        }
    }
    
    static func fetchClinicalCases(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchLikesForCase(caseId: String, completion: @escaping(Int) -> Void) {
        let likesRef = COLLECTION_CASES.document(caseId).collection("case-likes").count
        likesRef.getAggregation(source: .server) { snaphsot, _ in
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
    
    static func fetchCommentsForCase(caseId: String, completion: @escaping(Int) -> Void) {
        let commentsRef = COLLECTION_CASES.document(caseId).collection("comments")
        let query = commentsRef.whereField("visible", isGreaterThanOrEqualTo: 0).whereField("visible", isLessThanOrEqualTo: 1).count
        query.getAggregation(source: .server) { snaphsot, _ in
            if let likes = snaphsot?.count {
                completion(likes.intValue)
            }
        }
    }
    
    static func fetchUserVisibleCases(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).whereField("privacy", isEqualTo: 0).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).whereField("privacy", isEqualTo: 0).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    
    
    static func fetchUserSearchCases(user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("professions", arrayContains: user.discipline!).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        } else {
            let nextGroupToFetch = COLLECTION_CASES.whereField("professions", arrayContains: user.discipline!).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchCasesWithProfession(lastSnapshot: QueryDocumentSnapshot?, profession: String, completion: @escaping(QuerySnapshot) -> Void) {
        #warning("el query field s'ha cambiat")
        //let queryField = Profession.getAllProfessions().map( { $0.profession }).contains(profession) ? "professions" : "specialities"
        let queryField = Discipline.allCases.map { $0.name }.contains(profession) ? "professions" : "specialities"
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField(queryField, arrayContains: profession).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.whereField(queryField, isEqualTo: profession).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                guard snapshot.documents.last != nil else { return }
                completion(snapshot)
            }
        }
    }
    
    static func fetchTopCasesForTopic(topic: String, completion: @escaping([Case]) -> Void) {
        var count = 0
        let query = COLLECTION_CASES.whereField("professions", arrayContains: topic).limit(to: 3)
        query.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            
            cases.enumerated().forEach { index, clinicalCase in
                self.checkIfUserLikedCase(clinicalCase: clinicalCase) { like in
                    self.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { bookmark in
                        fetchLikesForCase(caseId: clinicalCase.caseId) { likes in
                            cases[index].likes = likes
                            fetchCommentsForCase(caseId: clinicalCase.caseId) { comments in
                                cases[index].numberOfComments = comments
                                cases[index].didLike = like
                                cases[index].didBookmark = bookmark
                                count += 1
                                if count == cases.count {
                                    completion(cases)
                                }
                            }
                        }
                    }
                }
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
    
    static func addCaseRevision(withCaseId caseId: String, revision: CaseRevision, completion: @escaping(Error?) -> Void) {
        let ref = COLLECTION_CASES.document(caseId).collection("case-revisions")
        
        let data: [String: Any] = ["timestamp": revision.timestamp,
                                   "content": revision.content,
                                   "kind": revision.kind.rawValue,
                                   "title": revision.title]
        ref.addDocument(data: data) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    static func fetchCaseRevisions(withCaseId caseId: String, completion: @escaping(Result<[CaseRevision], Error>) -> Void) {
        let ref = COLLECTION_CASES.document(caseId).collection("case-revisions")
        ref.getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                let revisions = snapshot.documents.map { CaseRevision(dictionary: $0.data() )}
                completion(.success(revisions))
            }
        }
    }
    
    static func editCasePhase(to stage: CasePhase, withCaseId caseId: String, withDiagnosis diagnosis: CaseRevision? = nil, completion: @escaping(Error?) -> Void) {
        COLLECTION_CASES.document(caseId).updateData(["phase": stage.rawValue]) { error in
            if let error {
                completion(error)
            } else {
                if let diagnosis {
                    let data: [String: Any] = ["content": diagnosis.content,
                                               "kind": diagnosis.kind.rawValue,
                                               "timestamp": Timestamp()]
                    
                    COLLECTION_CASES.document(caseId).collection("case-revisions").addDocument(data: data) { error in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }

    static func uploadCaseStage(withCaseId caseId: String, withGroupId groupId: String? = nil, completion: @escaping(Bool) -> Void) {
        
        COLLECTION_CASES.document(caseId).updateData(["phase": CasePhase.solved.rawValue]) { error in
            if let _ = error {
                print("error uploading diagnosis")
                completion(false)
            }
            completion(true)
        }
    }
    
    /*
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
    */
    
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
                if clinicalCase.privacy == .anonymous {
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
            getCaseValuesFor(clinicalCase: clinicalCase) { caseWithValues in
                completion(caseWithValues)
            }
        }
    }
    /*
    static func fetchGroupCase(withGroupId groupId: String, withCaseId caseId: String, completion: @escaping(Case) -> Void) {
        
        COLLECTION_GROUPS.document(groupId).collection("cases").document(caseId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let clinicalCase = Case(caseId: snapshot.documentID, dictionary: data)
            getGroupCaseValuesFor(clinicalCase: clinicalCase) { fetchedCase in
                completion(fetchedCase)
            }
            //getGroupCaseValuesFor(clinicalCase: clinicalCase) { fetchedCase in
            //    completion(fetchedCase)
            //}
            /*
             GroupService.fetchLikesForGroupCase(groupId: groupId, postId: caseId) { likes in
             clinicalCase.likes = likes
             CommentService.fetchNumberOfCommentsForCase(clinicalCase: clinicalCase, type: .group) { comments in
             clinicalCase.numberOfComments = comments
             completion(clinicalCase)
             }
             }
             */
        }
    }
    */
    static func likeCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let likeData = ["timestamp": Timestamp(date: Date())]
        //Add a new like to the post
        //Update posts likes collection to track likes for a particular post
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").document(uid).setData(likeData) { _ in
            //Update user likes collection to track likes for a particular user
            COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).setData(likeData, completion: completion)
        }
    }
    
    static func unlikeCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        guard clinicalCase.likes > 0 else { return }
        
        //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["likes" : clinicalCase.likes - 1])
        
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").document(uid).delete() { _ in
            COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedCase(clinicalCase: Case, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
      
            COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).getDocument { (snapshot, _) in
                //If the snapshot (document) exists, means current user did like the post
                guard let didLike = snapshot?.exists else { return }
                completion(didLike)
            
        }
    }
    
    static func bookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let bookmarkData = ["timestamp": Timestamp(date: Date())]
        //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["bookmarks" : clinicalCase.numberOfBookmarks + 1])
        
        //Update post bookmark collection to track bookmarks for a particular post
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-bookmarks").document(uid).setData(bookmarkData) { _ in
            //Update user bookmarks collection to track bookmarks for a particular user
            COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).setData(bookmarkData, completion: completion)
        }
    }
    
    static func unbookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //guard clinicalCase.numberOfBookmarks > 0 else { return }
        
        //COLLECTION_CASES.document(clinicalCase.caseId).updateData(["bookmarks" : clinicalCase.numberOfBookmarks - 1])
        
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
    
    static func getAllLikesFor(clinicalCase: Case, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            
            COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").limit(to: 30).getDocuments { snapshot, _ in
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
            COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, _ in
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
    
    static func fetchBookmarkedCaseDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-case-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.addSnapshotListener { snapshot, error in
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
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-case-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
            nextGroupToFetch.addSnapshotListener { snapshot, error in
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
    
    static func fetchCases(snapshot: QuerySnapshot, completion: @escaping([Case]) -> Void) {
        var cases = [Case]()
        snapshot.documents.forEach({ document in
            let caseSource = CaseSource(dictionary: document.data())
            fetchCase(withCaseId: document.documentID) { clinicalCase in
                cases.append(clinicalCase)
                if snapshot.count == cases.count {
                    cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    completion(cases)
                }
            }
        })
    }
    
    static func fetchCasesForYou(user: User, completion: @escaping([Case]) -> Void) {
        //Fetch posts by filtering according to timestamp
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let query = COLLECTION_CASES.whereField("ownerUid", isNotEqualTo: uid).whereField("professions", arrayContainsAny: [user.discipline!]).limit(to: 3)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {

                completion([])
                return
            }

            //Mapping that creates an array for each Case
            var cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            cases.enumerated().forEach { index, clinicalCase in
                self.checkIfUserLikedCase(clinicalCase: clinicalCase) { like in
                    self.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { bookmark in
                        CaseService.fetchLikesForCase(caseId: clinicalCase.caseId) { likes in
                            cases[index].likes = likes
                            CommentService.fetchNumberOfCommentsForCase(clinicalCase: clinicalCase) { comments in
                                cases[index].numberOfComments = comments
                                cases[index].didLike = like
                                cases[index].didBookmark = bookmark
                                if snapshot.count == cases.count {
                                    completion(cases)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    static func fetchCasesWithFilterCategoriesQuery(query: Case.FilterCategories, user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            switch query {
            case .explore:
                return
            case .all:
                let casesQuery = COLLECTION_CASES.limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
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
            case .recents:
                let firstGroupToFetch = COLLECTION_CASES.order(by: "timestamp", descending: true).limit(to: 10)
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
            case .you:
                let casesQuery = COLLECTION_CASES.whereField("disciplines", arrayContains: user.discipline!.rawValue).limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
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
            case .solved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.solved.rawValue).limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(snapshot!)
                        print("no snap")
                        return
                    }
                    
                    guard snapshot.documents.last != nil else {
                        completion(snapshot)
                        return
                    }
                    print("snap")
                    completion(snapshot)
                }
            case .unsolved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.unsolved.rawValue).limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
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
            switch query {
            case .explore:
                return
            case .all:
                let casesQuery = COLLECTION_CASES.limit(to: 10).start(afterDocument: lastSnapshot!)
                casesQuery.getDocuments { snapshot, error in
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
            case .recents:
                let firstGroupToFetch = COLLECTION_CASES.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .you:
                let casesQuery = COLLECTION_CASES.whereField("disciplines", arrayContains: user.discipline!).start(afterDocument: lastSnapshot!).limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
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
                
            case .solved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.solved.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
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
            case .unsolved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.unsolved.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                casesQuery.getDocuments { snapshot, error in
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






