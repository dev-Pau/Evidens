//
//  NewService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/3/23.
//

import UIKit
import Firebase

struct NewService {
    static func fetchTopNewsForYou(completion: @escaping([New]) -> Void) {
        COLLECTION_NEWS.order(by: "timestamp", descending: false).limit(to: 5).getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var news = snapshot.documents.map({ New(dictionary: $0.data()) })
            news.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
            completion(news)
        }
    }
    
    static func fetchTopRecentForYou(completion: @escaping([New]) -> Void) {
        COLLECTION_NEWS.order(by: "timestamp", descending: true).limit(to: 5).getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion([])
                return
            }
            
            var news = snapshot.documents.map({ New(dictionary: $0.data()) })
            news.sort(by: { $0.timestamp.seconds < $1.timestamp.seconds })
            completion(news)
        }
    }
    
    static func fetchNewsForYou(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_NEWS.order(by: "timestamp", descending: false).limit(to: 15)
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
            let nextGroupToFetch = COLLECTION_NEWS.order(by: "timestamp", descending: false).start(afterDocument: lastSnapshot!).limit(to: 15)
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
    
    static func fetchRecentNews(lastSnapshot: QueryDocumentSnapshot?, completion: @escaping(QuerySnapshot) -> Void) {
        if lastSnapshot == nil {
            let firstGroupToFetch = COLLECTION_NEWS.order(by: "timestamp", descending: true).limit(to: 15)
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
            let nextGroupToFetch = COLLECTION_NEWS.order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: 15)
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
}
