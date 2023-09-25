//
//  CaseService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit
import Firebase
import FirebaseAuth

struct CaseService {
    
    /// Adds a clinical case to the Firestore database.
    ///
    /// - Parameters:
    ///   - viewModel: The view model containing the case details.
    ///   - completion: A completion handler indicating the success or failure of the operation.
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
                            "visible": CaseVisibility.regular.rawValue,
                            "privacy": privacy.rawValue,
                            "timestamp": timestamp] as [String : Any]
        
        if viewModel.hasHashtags {
            clinicalCase["hashtags"] = viewModel.hashtags
        }
        
        let caseRef = COLLECTION_CASES.document()
        
        if viewModel.hasImages {
            clinicalCase["kind"] = CaseKind.image.rawValue
            StorageManager.addImages(toCaseId: caseRef.documentID, viewModel.images.map { $0.getImage() }) { result in
                switch result {
                case .success(let imageUrl):
                    print("we receive inamge sin case service already added")
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
                    print("we receive a failure in case service.. so basically case is not added")
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
    
    /// Adds a recently viewed case to the user's recent cases list if the case's privacy is regular.
    ///
    /// - Parameters:
    ///   - id: The ID of the case to be added to the recent cases list.
    ///   - privacy: The privacy setting of the case.
    static func addRecent(forCaseId id: String, privacy: CasePrivacy) {
        guard privacy == .regular else {
            return
        }
        
        DatabaseManager.shared.addRecentCase(withCaseId: id)
    }

    /// Fetches an array of cases using their IDs.
    ///
    /// - Parameters:
    ///   - caseIds: An array of case IDs to fetch.
    ///   - completion: A completion handler to be called with the result.
    static func fetchCases(withCaseIds caseIds: [String], completion: @escaping(Result<[Case], FirestoreError>) -> Void) {
        var cases = [Case]()
        let dispatchGroup = DispatchGroup()
        
        for caseId in caseIds {
            dispatchGroup.enter()
            
            fetchCase(withCaseId: caseId) { result in
                switch result {
                case .success(let clinicalCase):
                    cases.append(clinicalCase)
                case .failure(_):
                    break
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(.success(cases))
        }
    }
        
    /// Fetches raw Cases from Firestore with the specified case ID.
    /// - Parameters:
    ///   - caseIds: The unique identifiers of the cases to be fetched.
    ///   - completion: A completion handler that receives a result containing either the fetched Post or an error.
    static func getRawCases(withCaseIds caseIds: [String], completion: @escaping(Result<[Case], FirestoreError>) -> Void) {
        let group = DispatchGroup()
        var cases = [Case]()
        
        for id in caseIds {
            group.enter()
            
            COLLECTION_CASES.document(id).getDocument { snapshot, error in
                if let _ = error {
                    group.leave()
                } else {
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        group.leave()
                        return
                    }
                    
                    var caseLikes = 0
                    
                    // Get the last notification date for this post and kind
                    let date = DataService.shared.getLastDate(forContentId: id, withKind: .likeCase)
                    fetchLikesForCase(caseId: id, startingAt: date) { result in
                        switch result {
                            
                        case .success(let likes):
                            caseLikes = likes
                        case .failure(_):
                            caseLikes = 0
                        }
                        
                        var clinicalCase = Case(caseId: snapshot.documentID, dictionary: data)
                        clinicalCase.likes = caseLikes
                        cases.append(clinicalCase)
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(cases))
        }
    }
    
    /// Fetches a plain Case from Firestore with the specified post ID.
    /// - Parameters:
    ///   - caseId: The unique identifier of the clinical case to fetch.
    ///   - completion: A completion handler that receives a result containing either the fetched Case or an error.
    static func getPlainCase(withCaseId caseId: String, completion: @escaping(Result<Case, FirestoreError>) -> Void) {
        
        COLLECTION_CASES.document(caseId).getDocument { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    completion(.failure(.notFound))
                    return
                }
                let clinicalCase = Case(caseId: snapshot.documentID, dictionary: data)
                completion(.success(clinicalCase))
            }
        }
    }
    
    /// Retrieves additional values for a clinical case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The clinical case for which to retrieve additional values.
    ///   - completion: A completion handler to be called with the updated clinical case.
    static func getCaseValuesFor(clinicalCase: Case, completion: @escaping(Case) -> Void) {
        var auxCase = clinicalCase
        
        let group = DispatchGroup()
        
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
    
    /// Retrieves additional values for an array of clinical cases.
    ///
    /// - Parameters:
    ///   - cases: The array of clinical cases for which to retrieve additional values.
    ///   - completion: A completion handler to be called with the updated array of clinical cases.
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
    
    /// Fetches cases with a given hashtag from Firestore.
    ///
    /// - Parameters:
    ///   - hashtag: The hashtag to search for.
    ///   - lastSnapshot: The last document snapshot from the previous fetch (nil if it's the first fetch).
    ///   - completion: A completion handler to be called with the result of the fetch.
    static func fetchCasesWithHashtag(_ hashtag: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("hashtags", arrayContains: hashtag.lowercased()).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
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

            let nextGroupToFetch = COLLECTION_CASES.whereField("hashtags", arrayContains: hashtag.lowercased()).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                
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
    
    /// Fetches the number of likes for a clinical case from Firestore.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the clinical case.
    ///   - completion: A completion handler to be called with the result containing the number of likes.
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
    
    /// Fetches the count of likes for a specific case, optionally starting from a certain date.
    ///
    /// - Parameters:
    ///   - caseId: The unique identifier of the post.
    ///   - date: An optional `Date` representing the starting date to fetch likes from.
    ///   - completion: A closure that receives a result containing the like count or an error.
    static func fetchLikesForCase(caseId: String, startingAt date: Date?, completion: @escaping(Result<Int, FirestoreError>) -> Void) {
        guard let _ = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        if let date {
            let timestamp = Timestamp(date: date)
            let likesRef = COLLECTION_CASES.document(caseId).collection("case-likes").whereField("timestamp", isGreaterThan: timestamp).count
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
        } else {
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
    }
    
    /// Fetches the number of visible comments for a clinical case from Firestore.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the clinical case.
    ///   - completion: A completion handler to be called with the result containing the number of visible comments.
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
    
    /// Fetches cases for a specific user from Firestore based on the user's UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user.
    ///   - lastSnapshot: The last snapshot of the previous fetched page (optional).
    ///   - completion: A completion handler to be called with the result containing the fetched cases.
    static func fetchUserCases(forUid uid: String, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("uid", isEqualTo: uid).whereField("privacy", isEqualTo: CasePrivacy.regular.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.whereField("uid", isEqualTo: uid).whereField("privacy", isEqualTo: CasePrivacy.regular.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    /// Fetches cases based on a specific user's discipline from Firestore.
    ///
    /// - Parameters:
    ///   - user: The user for whom to fetch cases.
    ///   - lastSnapshot: The last snapshot of the previous fetched page (optional).
    ///   - completion: A completion handler to be called with the result containing the fetched cases.
    static func fetchUserSearchCases(user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let discipline = user.discipline else {
            completion(.failure(.unknown))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    /// Fetches a list of top cases based on the given discipline.
    ///
    /// - Parameters:
    ///   - discipline: The discipline for which top cases are to be fetched.
    ///   - completion: A completion block that receives the result containing either an array of top cases or an error.
    static func fetchTopCasesWithDiscipline(_ discipline: Discipline, completion: @escaping(Result<[Case], FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let query = COLLECTION_CASES.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 3)
        
        query.getDocuments { snapshot, error in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                var cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                
                for (index, clinicalCase) in cases.enumerated() {
                    dispatchGroup.enter()
                    getCaseValuesFor(clinicalCase: clinicalCase) { values in
                        cases[index] = values
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(cases))
                }
            }
        }
    }
    
    /// Adds a case revision to a specific case in Firestore.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case to which the revision will be added.
    ///   - revision: The case revision to be added.
    ///   - completion: A completion handler to be called after the revision is added or if an error occurs.
    static func addCaseRevision(withCaseId caseId: String, revision: CaseRevision, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = COLLECTION_CASES.document(caseId).collection("case-revisions")
        
        let data: [String: Any] = ["timestamp": revision.timestamp,
                                   "content": revision.content,
                                   "kind": revision.kind.rawValue,
                                   "title": revision.title as Any]
        ref.addDocument(data: data) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Fetches case revisions for a specific case from Firestore.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case for which revisions are fetched.
    ///   - completion: A completion handler to be called after fetching revisions or if an error occurs.
    static func fetchCaseRevisions(withCaseId caseId: String, completion: @escaping(Result<[CaseRevision], FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = COLLECTION_CASES.document(caseId).collection("case-revisions")
        ref.getDocuments { snapshot, error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, !snapshot.isEmpty else {
                    completion(.failure(.notFound))
                    return
                }
                
                let revisions = snapshot.documents.map { CaseRevision(dictionary: $0.data() )}
                completion(.success(revisions))
            }
        }
    }
    
    /// Edits the phase of a case in Firestore.
    ///
    /// - Parameters:
    ///   - stage: The new phase to set for the case.
    ///   - caseId: The ID of the case to edit.
    ///   - diagnosis: Optional diagnosis to add as a case revision.
    ///   - completion: A completion handler to be called after editing the case or if an error occurs.
    static func editCasePhase(to stage: CasePhase, withCaseId caseId: String, withDiagnosis diagnosis: CaseRevision? = nil, completion: @escaping(FirestoreError?) -> Void) {

        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }

        COLLECTION_CASES.document(caseId).updateData(["phase": stage.rawValue]) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                if let diagnosis {
                    let data: [String: Any] = ["content": diagnosis.content,
                                               "kind": diagnosis.kind.rawValue,
                                               "timestamp": Timestamp()]
                    
                    COLLECTION_CASES.document(caseId).collection("case-revisions").addDocument(data: data) { error in
                        if let _ = error {
                            completion(.unknown)
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
    
    /// Fetches a specific case from Firestore.
    ///
    /// - Parameters:
    ///   - caseId: The ID of the case to fetch.
    ///   - completion: A completion handler to be called with the fetched case or an error.
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
 
    /// Checks if the user has liked a specific case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The case to check for liking.
    ///   - completion: A completion handler to be called with the result indicating whether the user liked the case or not.
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
    
    /// Checks if the user has bookmarked a specific case.
    ///
    /// - Parameters:
    ///   - clinicalCase: The case to check for bookmarking.
    ///   - completion: A completion handler to be called with the result indicating whether the user bookmarked the case or not.
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
    
    /// Fetches bookmarked case documents for a specific user.
    ///
    /// - Parameters:
    ///   - lastSnapshot: The last document snapshot from the previous query (optional, used for pagination).
    ///   - completion: A completion handler to be called with the result containing the fetched documents.
    static func fetchBookmarkedCaseDocuments(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
    
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
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
    
    /// Fetches multiple cases based on a given query snapshot.
    ///
    /// - Parameters:
    ///   - snapshot: The query snapshot containing documents representing cases.
    ///   - completion: A completion handler to be called with the fetched cases.
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
        let query = COLLECTION_CASES.whereField("uid", isNotEqualTo: uid).whereField("disciplines", arrayContainsAny: [disciple.rawValue]).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 3)
        
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
    
    /// Fetches clinical cases from Firestore, with support for pagination.
    ///
    /// - Parameters:
    ///   - lastSnapshot: The last document snapshot from the previous fetch (or nil for the initial fetch).
    ///   - completion: A completion handler to be called with the fetched cases or an error.
    static func fetchClinicalCases(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    ///   - discipline: The optional discipline to filter cases by.
    ///   - speciality: The optional speciality to filter cases by.
    ///   - completion: A closure to be called when the fetch is completed.
    ///                 It takes a single parameter of type `Result<QuerySnapshot, FirestoreError>`.
    ///                 The result will be either `.success` with the fetched `QuerySnapshot` if successful,
    ///                 or `.failure` with a `FirestoreError` indicating the reason for failure.
    static func fetchCasesWithDiscipline(lastSnapshot: QueryDocumentSnapshot?, discipline: Discipline? = nil, speciality: Speciality? = nil, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
     
        var queryField = ""
        var queryValue = 0
        
        if let discipline {
            queryValue = discipline.rawValue
            queryField = "disciplines"
        } else if let speciality {
            queryValue = speciality.rawValue
            queryField = "specialities"
        }

        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_CASES.whereField(queryField, arrayContains: queryValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
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
            let nextGroupToFetch = COLLECTION_CASES.whereField(queryField, arrayContains: queryValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
    
    /// Fetches clinical cases with a specified filter.
    ///
    /// - Parameters:
    ///   - query: The filter criteria for fetching cases.
    ///   - user: The user whose information may be used for filtering.
    ///   - lastSnapshot: The last document snapshot from the previous fetch (or nil for the initial fetch).
    ///   - completion: A completion handler to be called with the fetched cases or an error.
    static func fetchCasesWithFilter(query: CaseFilter, user: User, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        if lastSnapshot == nil {
            switch query {
            case .explore:
                return
            case .all:
                let casesQuery = COLLECTION_CASES.whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .recents:
                let casesQuery = COLLECTION_CASES.order(by: "timestamp", descending: true).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .you:
                let casesQuery = COLLECTION_CASES.whereField("disciplines", arrayContains: user.discipline!.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .solved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.solved.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .unsolved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.unsolved.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            }
        } else {
            switch query {
            case .explore:
                return
            case .all:
                let casesQuery = COLLECTION_CASES.limit(to: 10).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!)
                fetchDocuments(for: casesQuery, completion: completion)
            case .recents:
                let casesQuery = COLLECTION_CASES.order(by: "timestamp", descending: true).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .you:
                let casesQuery = COLLECTION_CASES.whereField("disciplines", arrayContains: user.discipline!.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .solved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.solved.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            case .unsolved:
                let casesQuery = COLLECTION_CASES.whereField("phase", isEqualTo: CasePhase.unsolved.rawValue).whereField("visible", isEqualTo: CaseVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
                fetchDocuments(for: casesQuery, completion: completion)
            }
        }
    }
}

// MARK: - Write Operations

extension CaseService {
    
    /// Deletes a case with the given ID from the Firestore database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the case to be deleted.
    ///   - completion: A closure that will be called after the delete operation is attempted.
    ///                 If the operation is successful, the completion will be called with `nil`.
    ///                 If an error occurs during the operation, the completion will be called with an appropriate `FirestoreError`.
    static func deleteCase(withId id: String, privacy: CasePrivacy, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let deletedCase = ["visible": CaseVisibility.deleted.rawValue]
        
        COLLECTION_CASES.document(id).setData(deletedCase, merge: true) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                switch privacy {
                case .regular:
                    DatabaseManager.shared.deleteRecentCase(withId: id) { error in
                        if let _ = error {
                            completion(.unknown)
                        } else {
                            completion(nil)
                        }
                    }
                case .anonymous:
                    completion(nil)
                }
            }
        }
    }
}

// MARK: - Helpers

extension CaseService {
    
    /// Fetches Firestore documents based on a provided query.
    ///
    /// - Parameters:
    ///   - query: The Firestore query to execute.
    ///   - completion: A completion handler to be called with the fetched documents or an error.
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
    
    /// Add a like to a case.
    ///
    /// - Parameters:
    ///   - id: The ID of the case to be liked.
    ///   - completion: A closure that is called when the like operation is complete. It takes a `FirestoreError?` parameter indicating the result of the operation.
    static func likeCase(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_CASES.document(id).collection("case-likes").document(uid).setData(likeData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-likes").document(id).setData(likeData) { error in
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
    
    /// Remove a like from a case.
    ///
    /// - Parameters:
    ///   - id: The ID of the case from which the like should be removed.
    ///   - completion: A closure that is called when the unlike operation is complete. It takes a `FirestoreError?` parameter indicating the result of the operation.
    static func unlikeCase(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_CASES.document(id).collection("case-likes").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-likes").document(id).delete() { error in
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
    
    /// Bookmark a case.
    ///
    /// - Parameters:
    ///   - id: The ID of the case to be bookmarked.
    ///   - completion: A closure that is called when the bookmark operation is complete. It takes a `FirestoreError?` parameter indicating the result of the operation.
    static func bookmarkCase(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_CASES.document(id).collection("case-bookmarks").document(uid).setData(bookmarkData) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(id).setData(bookmarkData) { error in
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
    
    /// Unbookmark a case.
    ///
    /// - Parameters:
    ///   - id: The ID of the case to be unbookmarked.
    ///   - completion: A closure that is called when the unbookmark operation is complete. It takes a `FirestoreError?` parameter indicating the result of the operation.
    static func unbookmarkCase(withId id: String, completion: @escaping(FirestoreError?) -> Void) {
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
        COLLECTION_CASES.document(id).collection("case-bookmarks").document(uid).delete() { error in
            if let _ = error {
                completion(.unknown)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        COLLECTION_USERS.document(uid).collection("user-case-bookmarks").document(id).delete { error in
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






