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
        let group = DispatchGroup()
        
        for caseId in caseIds {
            group.enter()
            fetchCase(withCaseId: caseId) { result in
                switch result {
                    
                case .success(let clinicalCase):
                    cases.append(clinicalCase)
                case .failure(_):
                    break
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(cases)
        }
    }
    
    static func fetchCases(withCaseIds caseIds: [String], completion: @escaping(Result<[Case], FirestoreError>) -> Void) {
        var cases = [Case]()
        let dispatchGroup = DispatchGroup()
        
        for caseId in caseIds {
            dispatchGroup.enter()
            
            fetchCase(withCaseId: caseId) { result in
                switch result {
                case .success(let clinicalCase):
                    cases.append(clinicalCase)
                case .failure(let error):
                    print(error)
                    #warning("Post was not found so maybe its good to remove the reference from the collection of posts from the user")
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(.success(cases))
        }
    }
    
    static func getCaseValuesFor(clinicalCase: Case, completion: @escaping(Case) -> Void) {
        var auxCase = clinicalCase
        
        var group = DispatchGroup()
        
        group.enter()
        checkIfUserLikedCase(clinicalCase: clinicalCase) { result in
            switch result {
            case .success(let didLike):
                auxCase.didLike = didLike
            case .failure(_):
                auxCase.didLike = false
            }
            
            group.leave()
        }
        
        group.enter()
        checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { result in
            switch result {
            case .success(let didBookmark):
                auxCase.didBookmark = didBookmark
            case .failure(_):
                auxCase.didBookmark = false
            }
            
            group.leave()
        }
        
        group.enter()
        fetchLikesForCase(caseId: clinicalCase.caseId) { result in
            switch result {
            case .success(let likes):
                auxCase.likes = likes
            case .failure(_):
                auxCase.likes = 0
            }

            group.leave()
        }
        
        group.enter()
        fetchCommentsForCase(caseId: clinicalCase.caseId) { result in
            switch result {
            case .success(let comments):
                auxCase.numberOfComments = comments
            case .failure(_):
                auxCase.numberOfComments = 0
            }

            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(auxCase)
        }
    }
    
    static func getCaseValuesFor(cases: [Case], completion: @escaping([Case]) -> Void) {

        var auxCases = cases
        let dispatchGroup = DispatchGroup()
        
        cases.enumerated().forEach { index, clinicalCase in
            dispatchGroup.enter()
            getCaseValuesFor(clinicalCase: clinicalCase) { caseWithValues in
                auxCases[index] = caseWithValues
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(auxCases)
        }
    }
    
    static func fetchCasesWithHashtag(_ hashtag: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("hashtags", arrayContains: hashtag.lowercased()).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
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
        } else {
            // Append new posts
            let nextGroupToFetch = COLLECTION_CASES.whereField("hashtags", arrayContains: hashtag.lowercased()).start(afterDocument: lastSnapshot!).limit(to: 10)
                
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
    
    static func checkIfUserHasNewCasesToDisplay(category: CaseFilter, snapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
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
    
    static func fetchLikesForCase(caseId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        
        let likesRef = COLLECTION_CASES.document(caseId).collection("case-likes").count
        likesRef.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                if let likes = snapshot?.count {
                    completion(.success(likes.intValue))
                } else {
                    completion(.success(0))
                }
            }
        }
    }
    
    static func fetchCommentsForCase(caseId: String, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        let commentsRef = COLLECTION_CASES.document(caseId).collection("comments")
        let query = commentsRef.whereField("visible", isGreaterThanOrEqualTo: 0).whereField("visible", isLessThanOrEqualTo: 1).count
        query.getAggregation(source: .server) { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                if let comments = snapshot?.count {
                    completion(.success(comments.intValue))
                } else {
                    completion(.success(0))
                }
            }
        }
    }
    
    static func fetchUserCases(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("uid", isEqualTo: uid).whereField("privacy", isEqualTo: CasePrivacy.regular.rawValue).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
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
        } else {
            let nextGroupToFetch = COLLECTION_CASES.whereField("uid", isEqualTo: uid).whereField("privacy", isEqualTo: CasePrivacy.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
        let dispatchGroup = DispatchGroup()

        let query = COLLECTION_CASES.whereField("disciplines", arrayContains: topic).limit(to: 3)
        
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            
            cases.enumerated().forEach { index, clinicalCase in
                dispatchGroup.enter()
                getCaseValuesFor(clinicalCase: clinicalCase) { caseWithValues in
                    cases[index] = caseWithValues
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(cases)
            }
        }
    }
    
    static func uploadCaseUpdate(withCaseId caseId: String, withUpdate text: String, withGroupId groupId: String? = nil, completion: @escaping(Bool) -> Void) {
        
        COLLECTION_CASES.document(caseId).updateData(["updates": FieldValue.arrayUnion([text])]) { error in
            if let _ = error {
                print("error uploading")
                completion(false)
            }
            completion(true)
            
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
        let group = DispatchGroup()
        
        caseId.forEach { id in
            group.enter()
            
            fetchCase(withCaseId: id) { result in
                switch result {
                    
                case .success(let clinicalCase):
                    cases.append(clinicalCase)
                case .failure(_):
                    break
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(cases)
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
    
    static func fetchCase(withCaseId caseId: String, completion: @escaping(Result<Case, FirestoreError>) -> Void) {
        COLLECTION_CASES.document(caseId).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.unknown))
                    return
                }
                
                let clinicalCase = Case(caseId: snapshot.documentID, dictionary: data)
                getCaseValuesFor(clinicalCase: clinicalCase) { caseWithValues in
                    completion(.success(caseWithValues))
                }
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
    
    static func checkIfUserLikedCase(clinicalCase: Case, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
      
        COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(.success(false))
                    return
                }
                
                completion(.success(true))
            }
        }
    }
    
    static func checkIfUserBookmarkedCase(clinicalCase: Case, completion: @escaping(Result<Bool, FirestoreError>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(.success(false))
                    return
                }
                
                completion(.success(true))
            }
        }
    }
    
    /*
     static func getAllLikesFor(post: Post, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
         
         guard NetworkMonitor.shared.isConnected else {
             completion(.failure(.network))
             return
         }
         
         if lastSnapshot == nil {
             
             COLLECTION_POSTS.document(post.postId).collection("post-likes").limit(to: 30).getDocuments { snapshot, error in
                 if let _ = error {
                     completion(.failure(.unknown))
                 } else {
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
         } else {
             COLLECTION_POSTS.document(post.postId).collection("post-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, error in
                 if let _ = error {
                     completion(.failure(.unknown))
                 } else {
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
     }
     */
    
    
    static func fetchBookmarkedCaseDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }

        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_USERS.document(uid).collection("user-case-bookmarks").order(by: "timestamp", descending: true).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
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
        } else {
            let nextGroupToFetch = COLLECTION_USERS.document(uid).collection("user-case-bookmarks").order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    static func fetchCases(snapshot: QuerySnapshot, completion: @escaping([Case]) -> Void) {
        var cases = [Case]()
        let group = DispatchGroup()
        
        for document in snapshot.documents {
            group.enter()
            fetchCase(withCaseId: document.documentID) { result in
                switch result {
                    
                case .success(let clinicalCase):
                    cases.append(clinicalCase)
                case .failure(_):
                    break
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(cases)
        }
    }
    
    /*
     
     */
}

// MARK: - Fetch Operations
extension CaseService {
    
    /// Fetches suggested cases for the given user based on their discipline.
    ///
    /// - Parameters:
    ///   - user: The user for whom to fetch suggested cases.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<[Case], FirestoreError>`.
    ///                 The result will be either `.success` with an array of `Case` objects containing the suggested cases,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchSuggestedCases(forUser user: User, completion: @escaping(Result<[Case], FirestoreError>) -> Void) {
        guard let disciple = user.discipline else {
            completion(.failure(.unknown))
            return
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let query = COLLECTION_CASES.whereField("uid", isNotEqualTo: uid).whereField("disciplines", arrayContainsAny: [disciple.rawValue]).limit(to: 3)
        
        query.getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let group = DispatchGroup()
                var cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                
                for (index, clinicalCase) in cases.enumerated() {
                    group.enter()
                    getCaseValuesFor(clinicalCase: clinicalCase) { caseWithValues in
                        cases[index] = caseWithValues
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(cases))
                }
            }
        }
    }
    
    static func fetchClinicalCases(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
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
        } else {
            let nextGroupToFetch = COLLECTION_CASES.start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    /// Fetches cases with a specific discipline or speciality.
    ///
    /// - Parameters:
    ///   - lastSnapshot: An optional parameter representing the last snapshot of the previous fetch, if any.
    ///   - discipline: The name of the discipline or speciality to filter cases.
    ///   - completion: A closure to be called when the fetch is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the fetched `QuerySnapshot` if successful,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchCasesWithDiscipline(lastSnapshot: QueryDocumentSnapshot?, discipline: String, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
     
        let queryField = Discipline.allCases.map { $0.name }.contains(discipline) ? "disciplines" : "specialities"
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField(queryField, arrayContains: discipline).limit(to: 10)
            firstGroupToFetch.getDocuments { snapshot, error in
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
        } else {
            let nextGroupToFetch = COLLECTION_CASES.whereField(queryField, isEqualTo: discipline).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    static func fetchCasesWithFilter(query: CaseFilter, user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            switch query {
            case .explore:
                return
            case .all:
                let casesQuery = COLLECTION_CASES.limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .recents:
                let casesQuery = COLLECTION_CASES.order(by: "timestamp", descending: true).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .you:
                let casesQuery = COLLECTION_CASES.whereField("disciplines", arrayContains: user.discipline!.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .solved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.solved.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .unsolved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.unsolved.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            }
        } else {
            switch query {
            case .explore:
                return
            case .all:
                let casesQuery = COLLECTION_CASES.limit(to: 10).start(afterDocument: lastSnapshot!)
                fetchDocuments(for: casesQuery, completion: completion)
            case .recents:
                let casesQuery = COLLECTION_CASES.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .you:
                let casesQuery = COLLECTION_CASES.whereField("disciplines", arrayContains: user.discipline!).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .solved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.solved.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .unsolved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.unsolved.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            }
        }
    }
}

// MARK: - Helpers

extension CaseService {
    
    private static func fetchDocuments(for query: FirebaseFirestore.Query, completion: @escaping (Result<QuerySnapshot, FirestoreError>) -> Void) {
        query.getDocuments { snapshot, error in
            if let error {
                let nsError = error as NSError
                let _ = FirestoreErrorCode(_nsError: nsError)
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                completion(.success(snapshot))
            }
        }
    }
}

//MARK: - Miscellaneous

extension CaseService {
    
    /// Fetches all likes for a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The Case for which to fetch the likes.
    ///   - lastSnapshot: An optional parameter representing the last snapshot of the previous fetch, if any.
    ///   - completion: A closure to be called when the fetch is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the fetched `QuerySnapshot` if successful,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func getAllLikesFor(clinicalCase: Case, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            
            COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").limit(to: 30).getDocuments { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
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
            
        } else {
            COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").start(afterDocument: lastSnapshot!).limit(to: 30).getDocuments { snapshot, error in
                if let _ = error {
                    completion(.failure(.unknown))
                } else {
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
    }
    
    static func likeCase(clinicalCase: Case, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    static func unlikeCase(clinicalCase: Case, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let likeData = ["timestamp": Timestamp(date: Date())]
        
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-likes").document(clinicalCase.caseId).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    static func bookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        let bookmarkData = ["timestamp": Timestamp(date: Date())]
       
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-bookmarks").document(uid).setData(bookmarkData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).setData(bookmarkData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    static func unbookmarkCase(clinicalCase: Case, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        COLLECTION_CASES.document(clinicalCase.caseId).collection("case-bookmarks").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(clinicalCase.caseId).delete { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
}






