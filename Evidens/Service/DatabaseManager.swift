//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import MessageKit

/// Manager object to read and write data to real time firebase database
final class DatabaseManager {
    
    /// Shared instance of class
    public static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}


//MARK: - Account Management

extension DatabaseManager {
    
    public func insert(user: User, completion: @escaping(DatabaseError?) -> Void) {

        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(user.uid!)
        ref.setValue(["uid": user.uid!]) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    public func fetchHomeHelper(completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        database.child("users").child(uid).child("helpers").getData { error, snapshot in
            guard error == nil else {
                completion(false)
                return
            }
            
            if let result = snapshot?.value as? [String: Bool] {
                completion(result["home"] ?? false)
            }
        }
    }
    
    func updateHomeHelper(completion: @escaping(Bool) -> Void) {
       completion(true)
    }
    
    
    public func updateUserFirstName(firstName: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid)
        ref.updateChildValues(["firstName": firstName.capitalized]) { error, _ in
            if let _ = error {
                completion(false)
            }
            completion(true)
        }
    }
    
    public func updateUserLastName(lastName: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid)
        ref.updateChildValues(["lastName": lastName.capitalized]) { error, _ in
            if let _ = error {
                completion(false)
            }
            completion(true)
        }
    }
    
    public enum RTDError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Failed to fetch"
            }
        }
    }
}

//MARK: - User recent searches & users

extension DatabaseManager {
    
    /// Uploads current user recent searches with the field searched
    public func uploadRecentSearches(with searchedTopic: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents").child("searches")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                // Check if the searched topic is already saved from the past
                if recentSearches.contains(searchedTopic) {
                    completion(false)
                    return
                }

                if recentSearches.count == 3 {
                    recentSearches.removeFirst()
                    recentSearches.append(searchedTopic)
                } else {
                    recentSearches.append(searchedTopic)
                }
               
                ref.setValue(recentSearches) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchRecentSearches(completion: @escaping(Result<[String], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child("\(uid)/recents").child("searches")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            if let recentSearches = snapshot?.value as? [String] {
                completion(.success(recentSearches.reversed()))
            } else {
                completion(.success([]))
            }
        }
    }
    
    /// Uploads current user recent searches with the field searched
    public func uploadRecentUserSearches(withUid userUid: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, uid != userUid  else { return }
        let ref = database.child("users").child("\(uid)/recents").child("users")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                // Check if the searched topic is already saved from the past
                if recentSearches.contains(userUid) {
                    completion(false)
                    return
                }

                if recentSearches.count == 10 {
                    recentSearches.removeFirst()
                    recentSearches.append(userUid)
                } else {
                    recentSearches.append(userUid)
                }
               
                ref.setValue(recentSearches) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([userUid]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchRecentUserSearches(completion: @escaping(Result<[String], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child("\(uid)/recents").child("users")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            if let recentSearches = snapshot?.value as? [String] {
                completion(.success(recentSearches.reversed()))
            } else {
                completion(.success([]))
            }
        }
    }
    
    public func uploadRecentMessageSearches(with searchedTopic: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents").child("messages")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                // Check if the searched topic is already saved from the past
                if recentSearches.contains(searchedTopic) {
                    completion(false)
                    return
                }

                if recentSearches.count == 10 {
                    recentSearches.removeFirst()
                    recentSearches.append(searchedTopic)
                } else {
                    recentSearches.append(searchedTopic)
                }
               
                ref.setValue(recentSearches) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func fetchRecentMessageSearches(completion: @escaping(Result<[String], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child("\(uid)/recents").child("messages")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists() else {
                completion(.success([String]()))
                return
            }
            
            if let recentSearches = snapshot.value as? [String] {
                completion(.success(recentSearches.reversed()))
            }
        }
    }
    
    public func fetchRecentJobSearches(completion: @escaping(Result<[String], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child("\(uid)/recents").child("jobs")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists() else {
                completion(.success([String]()))
                return
            }
            
            if let recentSearches = snapshot.value as? [String] {
                completion(.success(recentSearches.reversed()))
            }
        }
    }
    
    public func fetchRecentGroupSearches(completion: @escaping(Result<[String], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child("\(uid)/recents").child("groups")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists() else {
                completion(.success([String]()))
                return
            }
            
            if let recentSearches = snapshot.value as? [String] {
                completion(.success(recentSearches.reversed()))
            }
        }
    }
    
    public func uploadRecentJobsSearches(with searchedTopic: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents").child("jobs")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                // Check if the searched topic is already saved from the past
                if recentSearches.contains(searchedTopic) {
                    completion(false)
                    return
                }

                if recentSearches.count == 10 {
                    recentSearches.removeFirst()
                    recentSearches.append(searchedTopic)
                } else {
                    recentSearches.append(searchedTopic)
                }
               
                ref.setValue(recentSearches) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func uploadRecentGroupSearches(with searchedTopic: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents").child("groups")
        
        // Check if user has recent searches
        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {
                // Recent searches document exists, append new search
                
                // Check if the searched topic is already saved from the past
                if recentSearches.contains(searchedTopic) {
                    completion(false)
                    return
                }

                if recentSearches.count == 10 {
                    recentSearches.removeFirst()
                    recentSearches.append(searchedTopic)
                } else {
                    recentSearches.append(searchedTopic)
                }
               
                ref.setValue(recentSearches) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            } else {
                // First time user searches, create a new document
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    public func deleteRecentMessageSearches(completion: @escaping(Result<Bool, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents/messages")
        ref.removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }
    }
    
    public func deleteRecentSearches(completion: @escaping(Result<Bool, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents")
        ref.removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }
    }
}

//MARK: - User Recent Comments

enum CommentType {
    case post
    case clinlicalCase
    
    var commentType: Int {
        switch self {
        case .post:
            return 0
        case .clinlicalCase:
            return 1
        }
    }
}

extension DatabaseManager {
    
    /// Uploads a comment to recents
    ///     /// Parameters:
    /// - `withUid`:   UID of the comment
    public func uploadRecentComments(withCommentUid commentUid: String, withRefUid refUid: String, title: String, comment: String, type: CommentType, withTimestamp timestamp: Date, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/comments").childByAutoId()
        
        let timestamp = NSDate().timeIntervalSince1970
        
        let newRecentComment = ["commentUid": commentUid,
                                "refUid": refUid,
                                "title": title,
                                "comment": comment,
                                "timestamp": timestamp,
                                "type": type.commentType] as [String : Any]
        
        ref.setValue(newRecentComment) { error, _ in
            print("Recent comment uploaded")
        }
    }
    
    public func fetchRecentComments(forUid uid: String, completion: @escaping(Result<[RecentComment], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("comments").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        
        var recentComments = [RecentComment]()

        let dispatchGroup = DispatchGroup()
        
        ref.observeSingleEvent(of: .value) { snapshot in

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else {
                    continue
                }
                
                var comment = RecentComment(dictionary: value)
                
                dispatchGroup.enter()
                
                self.getCommentsFromRecent(comment: comment) { result in
                    
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    switch result {
                    case .success(let comment):
                        if let comment {
                            recentComments.append(comment)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                //guard !comments.isEmpty, let timeInterval = comments.last?.timestamp else { return }
                //self.commentLastTimestamp = Int64(timeInterval * 1000)
                recentComments.sort(by: { $0.timestamp > $1.timestamp })
                completion(.success(recentComments))
            }
        }
    }
        
    public func fetchProfileComments(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[RecentComment], Error>) -> Void) {
        
        var recentComments = [RecentComment]()
        
        let dispatchGroup = DispatchGroup()
        
        if lastTimestampValue == nil {
            let ref = database.child("users").child(uid).child("profile").child("comments").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            
            ref.observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { continue }
                    
                    let recentComment = RecentComment(dictionary: value)

                    dispatchGroup.enter()
                    
                    self.getCommentsFromRecent(comment: recentComment) { result in
                        
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        switch result {
                        case .success(let comment):
                            if let comment {
                                recentComments.append(comment)
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(.success(recentComments))
                    }
                }
            }
        } else {
            // Fetch more posts
            let ref = database.child("users").child(uid).child("profile").child("comments").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)

            ref.observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    
                    let recentComment = RecentComment(dictionary: value)
                    
                    dispatchGroup.enter()
                    
                    self.getCommentsFromRecent(comment: recentComment) { result in
                        
                        defer {
                               dispatchGroup.leave()
                        }
                        
                        switch result {
                        case .success(let comment):
                            if let comment {
                                recentComments.append(comment)
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(recentComments))
                }
            }
        }
    }
    
    private func getCommentsFromRecent(comment: RecentComment, completion: @escaping(Result<RecentComment?, Error>) -> Void) {
        var auxComment = comment
        switch comment.source {
        case .post:
            switch comment.kind {
            case .comment:
                let ref = COLLECTION_POSTS.document(comment.referenceId).collection("comments").document(comment.id)
                
                ref.getDocument { snapshot, error in

                    if let error {
                        completion(.failure(error))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.success(nil))
                            return
                        }
                        
                        let userComment = Comment(dictionary: data)
                        auxComment.setComment(userComment.comment)
                        completion(.success(auxComment))
                    }
                }
            case .reply:
                // Post & Reply
                let ref = COLLECTION_POSTS.document(comment.referenceId).collection("comments").document(comment.commentId!).collection("comments").document(comment.id)
                
                ref.getDocument { snapshot, error in

                    if let error {
                        completion(.failure(error))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.success(nil))
                            return
                        }
                        
                        let userComment = Comment(dictionary: data)
                        auxComment.setComment(userComment.comment)
                        completion(.success(auxComment))
                    }
                }
            }
        case .clinicalCase:
            switch comment.kind {
            case .comment:
                // Case & Comment
                let ref = COLLECTION_CASES.document(comment.referenceId).collection("comments").document(comment.id)
                
                ref.getDocument { snapshot, error in
                    if let error {
                        completion(.failure(error))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.success(nil))
                            return
                        }
                        
                        let userComment = Comment(dictionary: data)
                        auxComment.setComment(userComment.comment)
                        completion(.success(auxComment))
                    }
                }
            case .reply:
                // Case & Reply
                let ref = COLLECTION_CASES.document(comment.referenceId).collection("comments").document(comment.commentId!).collection("comments").document(comment.id)
                
                ref.getDocument { snapshot, error in
                    
                    if let error {
                        completion(.failure(error))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.success(nil))
                            return
                        }
                        
                        let userComment = Comment(dictionary: data)
                        auxComment.setComment(userComment.comment)
                        completion(.success(auxComment))
                    }
                }
            }
        }
    }
    
    public func deleteRecentComment(forCommentId commentId: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("comments")
        let query = ref.queryOrdered(byChild: "id").queryEqual(toValue: commentId).queryLimited(toFirst: 1)
        
        query.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                if let key = value.keys.first {
                    ref.child(key).removeValue()
                }
            }
        }
    }
}



//MARK: - User Recent Posts

extension DatabaseManager {
    
    public func uploadRecentPost(withUid postUid: String, withDate date: Date, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/posts/\(postUid)/timestamp")
        
        let timestamp = NSDate().timeIntervalSince1970
        
        ref.setValue(timestamp) { error, _ in
            if let _ = error {
                completion(false)
            }
            completion(true)
        }
    }
    
    public func fetchRecentPosts(forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        
        var uids: [String] = []
        
        let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let values = snapshot.value as? [String: Any] {
                values.forEach { value in
                    uids.append(value.key)
                    if uids.count == values.count {
                        completion(.success(uids))
                    }
                }
            } else {
                completion(.success([]))
            }
        }
    }
    
    public func fetchHomeFeedPosts(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastTimestampValue == nil {
            let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    let postIds = values.map { $0.key }
                    completion(.success(postIds))
                } else {
                    completion(.failure(.unknown))
                }
            }
            
        } else {
            let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)

            ref.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    let postIds = values.map { $0.key }
                    completion(.success(postIds))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    } 
}

//MARK: - Report Posts & Cases

extension DatabaseManager {
    
    public func report(source: ReportSource, report: Report, completion: @escaping(DatabaseError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let target = report.target, let topic = report.topic else {
            completion(.unknown)
            return
            
        }
        var reportData = ["contentUid": report.contentUid,
                          "target": target.rawValue,
                          "topic": topic.rawValue,
                          "uid": report.uid] as [String : Any]
        
        if let content = report.content {
            reportData["content"] = content
        }
        
        let ref = database.child("reports").child(String(source.rawValue)).child(report.contentId).childByAutoId()
        ref.setValue(reportData) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    public func reportPost(forUid postUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
        let ref = database.child("reports").child("posts").child(postUid).childByAutoId()
        let reportData = ["uid": uid]
        ref.setValue(reportData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
}

//MARK: - Language

extension DatabaseManager {
    
    //MARK: - Write Operations
    
    /// Add a new language entry to the Firebase Realtime Database based on the provided `LanguageViewModel`.
    ///
    /// - Parameters:
    ///   - viewModel: The `LanguageViewModel` containing the language information to add.
    ///   - completion: A closure that will be called once the operation is completed or an error occurs.
    ///                 The closure receives a `DatabaseError?` parameter, where `nil` indicates success,
    ///                 and a `DatabaseError` indicates failure with the specific error type.
    public func addLanguage(viewModel: LanguageViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let kind = viewModel.kind,
              let proficiency = viewModel.proficiency else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("languages").queryOrdered(byChild: "kind").queryEqual(toValue: kind.rawValue)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard !snapshot.exists() else {
                completion(.exists)
                return
            }
            
            let data = ["kind": kind.rawValue,
                        "proficiency": proficiency.rawValue]
            let ref = strongSelf.database.child("users").child(uid).child("profile").child("sections").child("languages").childByAutoId()
            ref.setValue(data) { error, reference in
                if let _ = error {
                    completion(.unknown)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Update the proficiency value of a specific language entry in the Firebase Realtime Database based on the provided `LanguageViewModel`.
    ///
    /// - Parameters:
    ///   - viewModel: The `LanguageViewModel` containing the updated proficiency value and other required information.
    ///   - completion: A closure that will be called once the update is completed or an error occurs.
    ///                 The closure receives a `DatabaseError?` parameter, where `nil` indicates success,
    ///                 and a `DatabaseError` indicates failure with the specific error type.
    public func updateLanguage(viewModel: LanguageViewModel, completion: @escaping(DatabaseError?) -> Void) {

        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let kind = viewModel.kind,
              let proficiency = viewModel.proficiency else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("languages").queryOrdered(byChild: "kind").queryEqual(toValue: kind.rawValue)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard snapshot.exists(), let value = snapshot.value as? [String: Any], let key = value.first?.key else {
                completion(.unknown)
                return
            }
            
            let data = ["proficiency": proficiency.rawValue]
            let ref = strongSelf.database.child("users").child(uid).child("profile").child("sections").child("languages").child(key)
            ref.updateChildValues(data) { error, reference in
                if let _ = error {
                    completion(.unknown)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - Fetch Operations
    
    /// Fetches the user's language data from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which to fetch the language data.
    ///   - completion: A closure that will be called once the language data is retrieved or an error occurs.
    ///                 The closure receives a `Result` object with an array of `Language` objects on success
    ///                 and a `DatabaseError` on failure.
    public func fetchLanguages(forUid uid: String, completion: @escaping(Result<[Language], DatabaseError>) -> Void) {
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("languages").queryLimited(toFirst: 3)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let _ = self else { return }
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.failure(.empty))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var languages = [Language]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                dispatchGroup.enter()
                
                guard let value = child.value as? [String: Any] else {
                    dispatchGroup.leave()
                    completion(.failure(.unknown))
                    return
                }
                
                let language = Language(dictionary: value)
                languages.append(language)
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(languages))
            }
        }
    }

    /// Deletes a language data from the Firebase Realtime Database for a specific user.
    ///
    /// - Parameters:
    ///   - viewModel: The `LanguageViewModel` containing the information of the language to be deleted.
    ///   - completion: A closure that will be called once the language data is deleted or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func deleteLanguage(viewModel: LanguageViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let kind = viewModel.kind else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("languages").queryOrdered(byChild: "kind").queryEqual(toValue: kind.rawValue)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard snapshot.exists(), let value = snapshot.value as? [String: Any], let key = value.first?.key else {
                completion(.unknown)
                return
            }
            
            let ref = strongSelf.database.child("users").child(uid).child("profile").child("sections").child("languages").child(key)
            ref.removeValue { error, reference in
                if let _ = error {
                    completion(.unknown)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Deletes a language data from the Firebase Realtime Database for a specific user.
    ///
    /// - Parameters:
    ///   - language: The `Language` object representing the language to be deleted.
    ///   - completion: A closure that will be called once the language data is deleted or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func deleteLanguage(_ language: Language, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("languages").queryOrdered(byChild: "kind").queryEqual(toValue: language.kind.rawValue)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard snapshot.exists(), let value = snapshot.value as? [String: Any], let key = value.first?.key else {
                completion(.unknown)
                return
            }
            
            let ref = strongSelf.database.child("users").child(uid).child("profile").child("sections").child("languages").child(key)
            ref.removeValue { error, reference in
                if let _ = error {
                    completion(.unknown)
                } else {
                    completion(nil)
                }
            }
        }
    }
}

//MARK: - User Patents

extension DatabaseManager {
    
    public func uploadPatent(patent: Patent, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let patentData = ["title": patent.title,
                          "number": patent.number,
                          "contributors": patent.contributorUids] as [String : Any]
                         
        let ref = database.child("users").child(uid).child("profile").child("patents").childByAutoId()
        
        ref.setValue(patentData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    public func fetchPatents(forUid uid: String, completion: @escaping(Result<[Patent], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("patents")
        var recentPatents = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.success([Patent]()))
                return
            }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentPatents.append(value)
                if recentPatents.count == snapshot.children.allObjects.count {
                    let patents: [Patent] = recentPatents.compactMap { dictionary in
                        guard let title = dictionary["title"] as? String,
                              let number = dictionary["number"] as? String,
                              let contributors = dictionary["contributors"] as? [String] else { return nil }
                        return Patent(title: title, number: number, contributorUids: contributors)
                    }
                    completion(.success(patents))
                }
            }
        }
    }
    
    public func updatePatent(from oldPatent: Patent, to newPatent: Patent, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let patentData = ["title": newPatent.title,
                          "number": newPatent.number,
                          "contributors": newPatent.contributorUids] as [String: Any]
            
        
        let ref = database.child("users").child(uid).child("profile").child("patents").queryOrdered(byChild: "title").queryEqual(toValue: oldPatent.title)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let newRef = self.database.child("users").child(uid).child("profile").child("patents").child(key)
                newRef.setValue(patentData) { error, _ in
                    if let error = error {
                        print(error)
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func deletePatent(patent: Patent, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("patents").queryOrdered(byChild: "title").queryEqual(toValue: patent.title)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let newRef = self.database.child("users").child(uid).child("profile").child("patents").child(key)
                newRef.removeValue { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
        }
    }
}

//MARK: - User Publications

extension DatabaseManager {
    
    public func uploadPublication(publication: Publication, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let publicationData = ["title": publication.title,
                               "url": publication.url,
                               "date": publication.date,
                               "contributors": publication.contributorUids] as [String: Any]
      
        let ref = database.child("users").child(uid).child("profile").child("publications").childByAutoId()

        ref.setValue(publicationData) { error, _ in
            if let _ = error {
                completion(false)
                return
                
            }
            completion(true)
        }
    }
    
    public func fetchPublications(forUid uid: String, completion: @escaping(Result<[Publication], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("publications")
        var publicationData = [[String: Any]]()
        //var recentPublications = [Publication]()

        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.success([Publication]()))
                return
            }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                publicationData.append(value)
                if publicationData.count == snapshot.children.allObjects.count {
                    let publications: [Publication] = publicationData.compactMap { dictionary in
                        guard let title = dictionary["title"] as? String,
                              let url = dictionary["url"] as? String,
                              let date = dictionary["date"] as? String,
                              let contributors = dictionary["contributors"] as? [String] else { return nil }
                        return Publication(title: title, url: url, date: date, contributorUids: contributors)
                    }
                    completion(.success(publications))
                }
            }
        }
    }
    
    public func updatePublication(from oldPublication: Publication, to newPublication: Publication, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let publicationData = ["title": newPublication.title,
                               "url": newPublication.url,
                               "date": newPublication.date,
                               "contributors": newPublication.contributorUids] as [String: Any]

        let ref = database.child("users").child(uid).child("profile").child("publications").queryOrdered(byChild: "title").queryEqual(toValue: oldPublication.title)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                let newRef = self.database.child("users").child(uid).child("profile").child("publications").child(key)
                newRef.setValue(publicationData) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func deletePublication(publication: Publication, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("publications").queryOrdered(byChild: "title").queryEqual(toValue: publication.title)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let newRef = self.database.child("users").child(uid).child("profile").child("publications").child(key)
                newRef.removeValue { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    
}

//MARK: - User Education

extension DatabaseManager {
    
    public func uploadEducation(education: Education, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let educationData = ["school": education.school,
                             "degree": education.degree,
                             "field": education.fieldOfStudy,
                             "startDate": education.startDate,
                             "endDate": education.endDate]
      
        let ref = database.child("users").child(uid).child("profile").child("education").childByAutoId()
        
        ref.setValue(educationData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func fetchEducation(forUid uid: String, completion: @escaping(Result<[Education], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("education")
        var educationData = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.success([Education]()))
                return
            }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                educationData.append(value)
                if educationData.count == snapshot.children.allObjects.count {
                    let educations: [Education] = educationData.compactMap { dictionary in
                        guard let school = dictionary["school"] as? String,
                              let degree = dictionary["degree"] as? String,
                              let field = dictionary["field"] as? String,
                              let startDate = dictionary["startDate"] as? String,
                              let endDate = dictionary["endDate"] as? String else { return nil }
                        return Education(school: school, degree: degree, fieldOfStudy: field, startDate: startDate, endDate: endDate)
                    }
                    completion(.success(educations))
                }
            }
        }
    }
    
    /// Uploads education based on degree selected. In case the user has more than one degree, compares with school & field to find the exact child to update
    ///     /// Parameters:
    /// - `previousDegree`:     Degree to update by de user
    /// - `previousSchool`:     School to update by de user
    /// - `previousField`:       Field to update by de user
    /// - `school, degree & type, field, startDate, endDate`:   New values of education details
    public func updateEducation(from oldEducation: Education, to newEducation: Education, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let educationData = ["school": newEducation.school,
                             "degree": newEducation.degree,
                             "field": newEducation.fieldOfStudy,
                             "startDate": newEducation.startDate,
                             "endDate": newEducation.endDate]
        
        // Query to fetch based on previousDegree
        let ref = database.child("users").child(uid).child("profile").child("education").queryOrdered(byChild: "degree").queryEqual(toValue: oldEducation.degree)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            // Check if the user has more than one child with the same degree type
            if snapshot.children.allObjects.count > 1 {
                // The user has more than one degree type compare every snapshot with previous school & field
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    guard let previousUserField = value["field"] as? String, let previousUserSchool = value["school"] as? String else { return }
                    if previousUserField == oldEducation.fieldOfStudy && previousUserSchool == oldEducation.school {
                        // Found the exact child to update with the child.key
                        let newRef = self.database.child("users").child(uid).child("profile").child("education").child(child.key)
                        newRef.setValue(educationData) { error, _ in
                            if let error = error {
                                print(error)
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }
                }
            }
            else {
                // The user has only one degree type
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    // Update education child with the key obtained
                    let newRef = self.database.child("users").child(uid).child("profile").child("education").child(key)
                    newRef.setValue(educationData) { error, _ in
                        if let error = error {
                            print(error)
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func deleteEducation(education: Education, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("education").queryOrdered(byChild: "degree").queryEqual(toValue: education.degree)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count > 1 {
                // The user has more than one degree type compare every snapshot with previous school & field
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    guard let previousUserField = value["field"] as? String, let previousUserSchool = value["school"] as? String else { return }
                    if previousUserField == education.fieldOfStudy && previousUserSchool == education.school {
                        // Found the exact child to update with the child.key
                        let newRef = self.database.child("users").child(uid).child("profile").child("education").child(child.key)
                        newRef.removeValue { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                    }
                }
            } else {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    // Update education child with the key obtained
                    let newRef = self.database.child("users").child(uid).child("profile").child("education").child(key)
                    newRef.removeValue { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
}


//MARK: - User Experience

extension DatabaseManager {
    
    public func uploadExperience(experience: Experience, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
         
        let experienceData = ["role": experience.role,
                              "company": experience.company,
                              "startDate": experience.startDate,
                              "endDate": experience.endDate]
    
        let ref = database.child("users").child(uid).child("profile").child("experience").childByAutoId()
        
        ref.setValue(experienceData) { error, _ in
            if let _ = error {
                completion(false)
                return
                
            }
            completion(true)
        }
    }
    
    public func fetchExperience(forUid uid: String, completion: @escaping(Result<[Experience], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("experience")
        var recentExperience = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.success([Experience]()))
                return
            }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentExperience.append(value)
                if recentExperience.count == snapshot.children.allObjects.count {
                    let experiences: [Experience] = recentExperience.compactMap { dictionary in
                        guard let role = dictionary["role"] as? String,
                              let company = dictionary["company"] as? String,
                              let startDate = dictionary["startDate"] as? String,
                              let endDate = dictionary["endDate"] as? String else { return nil }
                        return Experience(role: role, company: company, startDate: startDate, endDate: endDate)
                    }
                    completion(.success(experiences))
                }
            }
        }
    }
    
    public func updateExperience(from oldExperience: Experience, to newExperience: Experience, completion: @escaping(Bool) -> Void) {
#warning("Waqui en comptes de fer tot aquest rollo simplement afegir id a experience que sigui un UUID().string i ja està")
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let experienceData = ["role": newExperience.role,
                              "company": newExperience.company,
                              "startDate": newExperience.startDate,
                              "endDate": newExperience.endDate]
        
        // Query to fetch based on previousDegree
        let ref = database.child("users").child(uid).child("profile").child("experience").queryOrdered(byChild: "role").queryEqual(toValue: oldExperience.role)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            // Check if the user has more than one child with the same degree type
            if snapshot.children.allObjects.count > 1 {
                // The user has more than one degree type compare every snapshot with previous school & field
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    guard let previousUserCompany = value["company"] as? String, let previousUserRole = value["role"] as? String else { return }
                    if previousUserCompany == oldExperience.company && previousUserRole == oldExperience.role {
                        // Found the exact child to update with the child.key
                        let newRef = self.database.child("users").child(uid).child("profile").child("experience").child(child.key)
                        newRef.setValue(experienceData) { error, _ in
                            if let error = error {
                                print(error)
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    }
                }
            }
            else {
                // The user has only one degree type
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    // Update education child with the key obtained
                    let newRef = self.database.child("users").child(uid).child("profile").child("experience").child(key)
                    newRef.setValue(experienceData) { error, _ in
                        if let error = error {
                            print(error)
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func deleteExperience(experience: Experience, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("experience").queryOrdered(byChild: "role").queryEqual(toValue: experience.role)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count > 1 {
                // The user has more than one degree type compare every snapshot with previous school & field
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    guard let previousUserCompany = value["company"] as? String else { return }
                    if previousUserCompany == experience.company {
                        // Found the exact child to update with the child.key
                        let newRef = self.database.child("users").child(uid).child("profile").child("experience").child(child.key)
                        newRef.removeValue { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                    }
                }
            } else {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    // Update education child with the key obtained
                    let newRef = self.database.child("users").child(uid).child("profile").child("experience").child(key)
                    newRef.removeValue { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
}
//MARK: - User Recent Cases

extension DatabaseManager {
    
    public func addRecentCase(withCaseId caseId: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("cases").child(caseId).child("timestamp")
        
        let timestamp = NSDate().timeIntervalSince1970
        
        ref.setValue(timestamp)
    }
    
    public func fetchRecentCases(forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        var uids: [String] = []
        
        let ref = database.child("users").child(uid).child("profile").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let values = snapshot.value as? [String: Any] {
                values.forEach { value in
                    uids.append(value.key)
                    if uids.count == values.count {
                        completion(.success(uids))
                    }
                }
            } else {
                completion(.success([]))
            }
        }
    }
    
    public func checkIfUserHasMoreThanThreeVisibleCases(forUid uid: String, completion: @escaping(Int) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        ref.observeSingleEvent(of: .value) { snapshot  in
            if let values = snapshot.value as? [String: Any] {
                completion(values.count)
                return
            
            } else {
                completion(0)
            }
        }
    }
}

//MARK: - User Sections

extension DatabaseManager {
    
}

// MARK: - Notifications manager

extension DatabaseManager {
    func uploadNotificationToken(tokenID: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("tokens").child(uid)
        ref.setValue(tokenID)
    }
}

//MARK: - Sending messages & Conversations+
extension DatabaseManager {
    
    public func createNewConversation(_ conversation: Conversation, with message: Message, completion: @escaping(Error?) -> Void) {
        guard let conversationId = conversation.id else {
            completion(nil)
            return
        }
        
        let messageData: [String: Any] = [
            "kind": message.kind.rawValue,
            "text": message.text,
            "date": message.sentDate.timeIntervalSince1970,
            "senderId": message.senderId
        ]

        database.child("conversations/\(conversationId)/messages").child(message.messageId).setValue(messageData) { [weak self] error, _ in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    public func checkForNewConversations(with conversationIds: [String], completion: @escaping([String]) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users/\(uid)/conversations").queryOrdered(byChild: "sync").queryEqual(toValue: false)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion([])
                return
            }
            
            var conversationIds = [String]()
            if let values = snapshot.value as? [String: Any] {
                for value in values {
                    conversationIds.append(value.key)
                }
                
                completion(conversationIds)
            }
        }
    }
    
    public func fetchNewConversations(with conversationIds: [String], completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        let group = DispatchGroup()
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        for id in conversationIds {
            let ref = database.child("users/\(uid)/conversations/\(id)")
            group.enter()
            ref.observeSingleEvent(of: .value) { snapshot in
                defer {
                    group.leave()
                }
                
                guard snapshot.exists() else {
                    return
                }

                guard let value = snapshot.value as? [String: Any], let userId = value["userId"] as? String, let timeInterval = value["date"] as? TimeInterval else {
                    return
                }
                
                group.enter()
                
                
                
                UserService.fetchUser(withUid: uid) { [weak self] result in
                 
                    defer {
                        group.leave()
                    }

                    switch result {
                    case .success(let user):

                        group.enter()
                        FileGateway.shared.saveImage(url: user.profileUrl, userId: userId) { url in
                            defer {
                                group.leave()
                            }
                            
                            let date = Date(timeIntervalSince1970: timeInterval)
                            let name = user.firstName! + " " + user.lastName!
                            let conversation = Conversation(id: id, userId: userId, name: name, date: date, image: url?.absoluteString ?? nil)
                            conversations.append(conversation)
                        }
                    case .failure(let error):
                        #warning("finish ere")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(conversations)
        }
    }
    
    public func deleteConversation(_ conversation: Conversation, completion: @escaping(Result<Bool, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let id = conversation.id else {
            return
        }
        let ref = database.child("users/\(uid)/conversations/\(id)")
        ref.removeValue { error, _ in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    public func fetchMessages(for conversations: [Conversation], completion: @escaping(Bool) -> Void) {
        let group = DispatchGroup()
        
        for conversation in conversations {
            let date = conversation.date ?? Date()
            let timeInterval = date.toUTCTimestamp()
            let conversationId = conversation.id!

            let ref = database.child("conversations/\(conversationId)/messages").queryOrdered(byChild: "date").queryStarting(atValue: timeInterval)
            
            group.enter()
            ref.observeSingleEvent(of: .value) { snapshot in
                defer {
                    group.leave()
                }

                guard snapshot.exists() else {
                    print("snapshot not exist")
                    return
                }
                
                guard let messages = snapshot.value as? [String: [String: Any]] else {
                    print("bad snapshot format")
                    return
                }
                print("we found messages")
                var newMessages = [Message]()
                for (messageId, message) in messages {
                    var newMessage = Message(dictionary: message, messageId: messageId)
                    
                    if newMessage.image != nil {
                        group.enter()
                        FileGateway.shared.saveImage(url: newMessage.image, userId: newMessage.messageId) { url in
                            if let url = url {
                                newMessage.updateImage(url.absoluteString)
                                newMessages.append(newMessage)
                                group.leave()
                            }
                        }
                    }
                    
                    newMessages.append(newMessage)
                }

                newMessages.sort(by: { $0.sentDate > $1.sentDate })
                print(newMessages)
                DataService.shared.save(conversation: conversation, latestMessage: newMessages.removeFirst())
                for newMessage in newMessages {
                    print("saving message")
                    print(newMessage)
                    DataService.shared.save(message: newMessage, to: conversation)
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(true)
        }
    }
    
    public func fetchNewMessages(for conversations: [Conversation], completion: @escaping(Bool) -> Void) {
        let group = DispatchGroup()
        
        for conversation in conversations {
            guard let latestMessage = conversation.latestMessage else { continue }
            let date = latestMessage.sentDate
            let timeInterval = date.toUTCTimestamp()
            let conversationId = conversation.id!

            let ref = database.child("conversations/\(conversationId)/messages").queryOrdered(byChild: "date").queryStarting(afterValue: timeInterval)
            
            group.enter()
            ref.observeSingleEvent(of: .value) { snapshot in
                defer {
                    group.leave()
                }
                
                guard snapshot.exists() else {
                    return
                }
                
                guard let messages = snapshot.value as? [String: [String: Any]] else {
                    return
                }
                
                var newMessages = [Message]()
                for (messageId, message) in messages {
                    var newMessage = Message(dictionary: message, messageId: messageId)
                    
                    if newMessage.image != nil {
                        group.enter()
                        FileGateway.shared.saveImage(url: newMessage.image, userId: newMessage.messageId) { url in
                            if let url = url {
                                newMessage.updateImage(url.absoluteString)
                                newMessages.append(newMessage)
                                group.leave()
                            }
                        }
                    }
                    
                    newMessages.append(newMessage)
                }
                
                newMessages.sort(by: { $0.sentDate < $1.sentDate })
                for newMessage in newMessages {
                    DataService.shared.save(message: newMessage, to: conversation)
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(true)
        }
    }
    
    public func toggleSync(for conversations: [Conversation]) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        for conversation in conversations {
            print(conversation.id!)
            let ref = database.child("users/\(uid)/conversations/\(conversation.id!)/sync")
            ref.setValue(true)
            
        }
    }
    
    public func sendMessage(to conversation: Conversation, with message: Message, completion: @escaping(Error?) -> Void) {
        guard let conversationId = conversation.id else {
            completion(nil)
            return
        }
        
        var messageData: [String: Any] = [
            "kind": message.kind.rawValue,
            "text": message.text,
            "date": message.sentDate.toUTCTimestamp(),
            "senderId": message.senderId
        ]
        
        if let image = message.image {
            messageData["image"] = image
        }
        
        database.child("conversations/\(conversationId)/messages").child(message.messageId).setValue(messageData) { [weak self] error, _ in
            guard let _ = self else { return }
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    public func observeNewMessages(on conversations: [Conversation], completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let conversationIds = conversations.map { $0.id! }
        for conversation in conversations {
            guard let conversationId = conversation.id, let latestMessage = conversation.latestMessage else { return }
            print(latestMessage.sentDate.toUTCTimestamp())
            #warning("aqui a sota no pots fer per date, això és la conversation date i no està inclos, ferho per sync i afegir els lsiteners quan vaig obtenint les conversatcions no just despres de load conversations perquè puc veure algo que noe stà sync i després tornarho a incloure.")
            let ref = database.child("users/\(uid)/conversations/\(conversationId)").queryOrdered(byChild: "sync").queryEqual(toValue: true)
            ref.observe(.value) { snapshot in
                print("we got a new message ltes see if exists in our query")
                guard snapshot.exists() else {
                    print("snapshot doesnt exist")
                    return
                }
                guard let sync = snapshot.childSnapshot(forPath: "sync").value as? Bool, !sync else { return }
                if let latestMessage = snapshot.childSnapshot(forPath: "latestMessage").value as? String {
                    print("We got something new")
                    self.fetchMessage(withId: latestMessage, for: conversationId) { error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        } else {
                            print("We fetched the message")
                            completion(conversationId)

                        }
                    }
                }
            }
        }
    }
    
    public func observeConversation(conversation: Conversation, completion: @escaping(Message) -> Void) {
        guard let latestMessage = conversation.latestMessage else { return }
        guard let id = conversation.id, let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let conversationRef = database.child("conversations/\(id)/messages").queryOrdered(byChild: "date").queryStarting(afterValue: latestMessage.sentDate.toUTCTimestamp())
        
        conversationRef.observe(.childAdded) { snapshot in
            guard snapshot.exists() else {
                return
            }
            
            guard let messageData = snapshot.value as? [String: Any] else { return }
            let messageId = snapshot.key
            let newMessage = Message(dictionary: messageData, messageId: messageId)
            guard uid != newMessage.senderId else { return }
            completion(newMessage)
        }
    }
    
    public func observeNewConversations(completion: @escaping(Conversation) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let ref = database.child("users/\(uid)/conversations").queryOrdered(byChild: "date").queryStarting(afterValue: Date().toUTCTimestamp())
        ref.observe(.childAdded) { snapshot in
            print("we got new root convesration")
            guard snapshot.exists() else {
                return
            }
            
            guard let value = snapshot.value as? [String: Any], let userId = value["userId"] as? String, let timeInterval = value["date"] as? TimeInterval, let sync = value["sync"] as? Bool, !sync  else {
                return
            }
            print("we got new root convesration")
            let conversationId = snapshot.key
            
            
            
            
            UserService.fetchUser(withUid: uid) { [weak self] result in

                switch result {
                case .success(let user):
                    FileGateway.shared.saveImage(url: user.profileUrl, userId: userId) { url in
                        let date = Date(timeIntervalSince1970: timeInterval)
                        let name = user.firstName! + " " + user.lastName!
                        let conversation = Conversation(id: conversationId, userId: userId, name: name, date: date, image: url?.absoluteString ?? nil)
                        completion(conversation)
                    }
                case .failure(let error):
                    print("finish here")
                    //strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
        
    public func fetchMessage(withId messageId: String, for conversationId: String, completion: @escaping(Error?) -> Void) {
        let ref = database.child("conversations/\(conversationId)/messages/\(messageId)")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                return
            }
            
            guard let messages = snapshot.value as? [String: Any], let message = messages.first else {
                return
            }
            
            var newMessage = Message(dictionary: messages, messageId: message.key)
            print(newMessage)
            if newMessage.image != nil {
                FileGateway.shared.saveImage(url: newMessage.image, userId: newMessage.messageId) { url in
                    if let url = url {
                        newMessage.updateImage(url.absoluteString)
                        print("is image")
                        DataService.shared.save(message: newMessage, to: conversationId)
                        completion(nil)
                    }
                }
            } else {
                DataService.shared.save(message: newMessage, to: conversationId)
                print("message saved")
                completion(nil)
            }
        }
    }
    
    public func observeConversations(completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users/\(uid)/conversations").queryOrdered(byChild: "sync").queryEqual(toValue: false)
        ref.observe(.value) { snapshot in
            print("we got a new message ltes see if exists in our query")
            
            guard snapshot.exists() else {
                print("snapshot doesnt exist")
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else {
                    print("we couldt get any snaphsot")
                    //completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                guard let userId = child.childSnapshot(forPath: "userId").value as? String else { return }
                let conversationId = child.key
                
                DataService.shared.conversationExists(for: userId) { exists in
                    if exists {
                        print("Existing Conversation")
                        if let conversation = DataService.shared.getConversation(with: conversationId) {
                            self.fetchMessages(for: conversation) { fetched in
                                if fetched {
                                    print("messages for conversation fetched")
                                    completion(conversationId)
                                }
                            }
                            
                            
                        }
                    } else {
                        print("New Conversation")
                        guard let timeInterval = value["date"] as? TimeInterval else {
                            return
                        }
                        let date = Date(timeIntervalSince1970: timeInterval)
                        
                        
                        
                        
                        UserService.fetchUser(withUid: uid) { result in

                            switch result {
                            case .success(let user):
                                FileGateway.shared.saveImage(url: user.profileUrl, userId: userId) { [weak self] url in
                                    let name = user.firstName! + " " + user.lastName!
                                    let conversation = Conversation(id: conversationId, userId: userId, name: name, date: date, image: url?.absoluteString ?? nil)
                                   
                                    self?.fetchMessages(forNewConversation: conversation) { fetched in
                                        if fetched {
                                            print("messages for new conversation fetched")
                                            completion(conversationId)
                                        }
                                    }
                                }
                            case .failure(let error):
                                #warning("here finish")
                            }
                        }
                    }
                }
/*
                guard let sync = snapshot.childSnapshot(forPath: "sync").value as? Bool, !sync else { return }
                if let latestMessage = snapshot.childSnapshot(forPath: "latestMessage").value as? String {
                    print("We got something new")
                    let conversationId = snapshot.key
                    DataService.shared.conversationExists(for: conversationId) { exists in
                        if exists {
                            // get conversation and check our last message and fetch from that point
                            print("existing conversation")
                        } else {
                            // fetch all messages from creation date
                            print("new conversation")
                        }
                    }
                    
                    
                    /*
                     self.fetchMessages(for: <#T##[Conversation]#>, completion: <#T##(Bool) -> Void#>)
                     self.fetchMessage(withId: latestMessage, for: conversationId) { error in
                     if let error = error {
                     print(error.localizedDescription)
                     return
                     } else {
                     print("We fetched the message")
                     completion(conversationId)
                     
                     }
                     }
                     */
 */
            }
            
        }
    }
    
    public func fetchMessages(for conversation: Conversation, completion: @escaping(Bool) -> Void) {
        let group = DispatchGroup()
        guard let latestMessage = conversation.latestMessage else { return }
        let date = latestMessage.sentDate
        let timeInterval = date.toUTCTimestamp()
        let conversationId = conversation.id!
        
        let ref = database.child("conversations/\(conversationId)/messages").queryOrdered(byChild: "date").queryStarting(afterValue: timeInterval)
        group.enter()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            defer {
                group.leave()
            }
            
            guard snapshot.exists() else {
                print("snapshot not exist")
                return
            }
            
            guard let messages = snapshot.value as? [String: [String: Any]] else {
                print("bad snapshot format")
                return
            }
            print("we found messages")
            var newMessages = [Message]()
            for (messageId, message) in messages {
                
                let exists = DataService.shared.messageExists(for: messageId)
                guard !exists else { continue }
 
                var newMessage = Message(dictionary: message, messageId: messageId)
                
                if newMessage.image != nil {
                    group.enter()
                    FileGateway.shared.saveImage(url: newMessage.image, userId: newMessage.messageId) { url in
                        if let url = url {
                            newMessage.updateImage(url.absoluteString)
                            newMessages.append(newMessage)
                            group.leave()
                        }
                    }
                }
                
                newMessages.append(newMessage)
            }
            
            #warning("revisar si ha d'anar al revés")
            newMessages.sort(by: { $0.sentDate < $1.sentDate })
            print(newMessages)
            //DataService.shared.save(conversation: conversation, latestMessage: newMessages.removeFirst())
            for newMessage in newMessages {
                group.enter()
                print("saving message")
                print(newMessage)
                DataService.shared.save(message: newMessage, to: conversation)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.toggleSync(for: [conversation])
            completion(true)
        }
    }
    
    public func fetchMessages(forNewConversation conversation: Conversation, completion: @escaping(Bool) -> Void) {
        guard let date = conversation.date else { return }
        let group = DispatchGroup()
        let timeInterval = date.toUTCTimestamp()
        let conversationId = conversation.id!
        
        let ref = database.child("conversations/\(conversationId)/messages").queryOrdered(byChild: "date").queryStarting(atValue: timeInterval)
        group.enter()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            defer {
                group.leave()
            }
            
            guard snapshot.exists() else {
                print("snapshot not exist")
                return
            }
            
            guard let messages = snapshot.value as? [String: [String: Any]] else {
                print("bad snapshot format")
                return
            }
            print("we found messages of new conversation")
            var newMessages = [Message]()
            for (messageId, message) in messages {
                var newMessage = Message(dictionary: message, messageId: messageId)
                
                if newMessage.image != nil {
                    group.enter()
                    FileGateway.shared.saveImage(url: newMessage.image, userId: newMessage.messageId) { url in
                        if let url = url {
                            newMessage.updateImage(url.absoluteString)
                            newMessages.append(newMessage)
                            group.leave()
                        }
                    }
                }
                
                newMessages.append(newMessage)
            }
            
            newMessages.sort(by: { $0.sentDate < $1.sentDate })
            print(newMessages)
            DataService.shared.save(conversation: conversation, latestMessage: newMessages.removeFirst())
            for newMessage in newMessages {
                group.enter()
                print("saving message of new conversation")
                print(newMessage)
                DataService.shared.save(message: newMessage, to: conversation)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.toggleSync(for: [conversation])
            completion(true)
        }
    }
}

//MARK: - Sections

extension DatabaseManager {
    
    //MARK: - Fetch Operations
    
    /// Fetches the "About" section content for the user with the provided UID.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user for whom to fetch the "About" section.
    ///   - completion: A closure to be called when the fetch process is completed.
    ///                 It takes a single parameter of type `Result<String, DatabaseError>`.
    ///                 The result will be either `.success` with the "About" section content as a `String`,
    ///                 or `.failure` with a `DatabaseError` indicating the reason for failure.
    public func fetchAboutUs(forUid uid: String, completion: @escaping(Result<String, DatabaseError>) -> Void) {
        let ref = database.child("users").child("\(uid)/profile/sections/about")
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        ref.getData { error, snapshot in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists() else {
                    completion(.success(""))
                    return
                }
                
                if let about = snapshot.value as? String {
                    completion(.success(about))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    //MARK: - Write Operations
    
    /// Adds the specified text to the user's profile section about in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - aboutText: The text to be added to the user's profile section about.
    ///   - completion: A closure to be called when the operation is completed. It takes a single parameter of type `DatabaseError?`.
    ///                 The parameter will be `nil` if the operation is successful, otherwise it will contain a `DatabaseError`
    ///                 indicating the reason for failure.
    public func addAboutUs(withText aboutText: String, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/sections/about")
        ref.setValue(aboutText) { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}
