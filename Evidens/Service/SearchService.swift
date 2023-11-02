//
//  SearchService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/23.
//

import UIKit
import Firebase

struct SearchService {
    
    /// Fetches content based on the provided discipline and search topic.
    ///
    /// - Parameters:
    ///   - discipline: The discipline of the content to fetch.
    ///   - searchTopic: The search topic for the content (people, posts, or cases).
    ///   - lastSnapshot: The last snapshot of the previous fetched content for pagination.
    ///   - completion: A closure to be called once the content is fetched or an error occurs.
    static func fetchContentWithDisciplineAndTopic(discipline: Discipline, searchTopic: SearchTopics, lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(Result<QuerySnapshot, FirestoreError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastSnapshot == nil {
            switch searchTopic {
            case .people:
                let firstGroupToFetch = COLLECTION_USERS.whereField("phase", isEqualTo: UserPhase.verified.rawValue).whereField("uid", isNotEqualTo: uid).whereField("discipline", isEqualTo: discipline.rawValue).limit(to: 25)
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
            case .posts:
                let firstGroupToFetch = COLLECTION_POSTS.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).limit(to: 10)
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
            case .cases:
                let firstGroupToFetch = COLLECTION_CASES.whereField("disciplines", arrayContains: discipline.rawValue).limit(to: 10)
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
            case .featured:
                break
            }
        } else {
            switch searchTopic {
            case .people:
                let firstGroupToFetch = COLLECTION_USERS.whereField("discipline", isEqualTo: discipline.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .posts:
                let firstGroupToFetch = COLLECTION_POSTS.whereField("disciplines", arrayContains: discipline.rawValue).whereField("visible", isEqualTo: PostVisibility.regular.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .cases:
                let firstGroupToFetch = COLLECTION_CASES.whereField("disciplines", arrayContains: discipline.rawValue).start(afterDocument: lastSnapshot!).limit(to: 10)
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
            case .featured:
                break
            }
        }
    }
}
