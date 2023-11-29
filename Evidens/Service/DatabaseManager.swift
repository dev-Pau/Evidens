//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase

/// Manager object to read and write data to real time firebase database
final class DatabaseManager {
    
    /// Shared instance of class
    public static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

//MARK: - User Recent Searches & Users

extension DatabaseManager {
    
    /// Adds a recently searched topic for the user.
    ///
    /// - Parameters:
    ///   - searchedTopic: The topic that was searched.
    public func addRecentSearch(with searchedTopic: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents").child("searches")

        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {

                if recentSearches.contains(searchedTopic) {
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
                        return
                    }
                }
            } else {
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        return
                    }
                }
            }
        }
    }
    
    /// Fetches a user's recent searches from the database.
    ///
    /// - Parameters:
    ///   - completion: A completion block that receives the result containing either an array of recent searches or an error.
    public func fetchRecentSearches(completion: @escaping(Result<[String], DatabaseError>) -> Void) {

        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = database.child("users").child("\(uid)/recents").child("searches")
        ref.getData { error, snapshot in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists(), let values = snapshot.value as? [String] else {
                    completion(.failure(.empty))
                    return
                }
                completion(.success(values.reversed()))
            }
        }
    }
    
    
    
    /// Adds a recently searched user UID for the current user.
    ///
    /// - Parameters:
    ///   - userUid: The UID of the user that was searched.
    public func addRecentUserSearches(withUid userUid: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, uid != userUid  else { return }
        let ref = database.child("users").child("\(uid)/recents").child("users")

        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {

                if recentSearches.contains(userUid) {
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
                        return
                    }
                }
            } else {
                ref.setValue([userUid]) { error, _ in
                    if let _ = error {
                        return
                    }
                }
            }
        }
    }
    
    public func deleteRecentSearches(completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let searchesRef = database.child("users").child("\(uid)/recents/searches")
        let usersRef = database.child("users").child("\(uid)/recents/users")
        
        var errorEncountered: Bool = false
        
        let group = DispatchGroup()
        
        group.enter()
        searchesRef.removeValue { error, _ in
            if let _ = error {
                errorEncountered = true
                
            }
            
            group.leave()
        }
        
        group.enter()
        usersRef.removeValue { error, _ in
            if let _ = error {
                errorEncountered = true
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            if errorEncountered {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Fetches a user's recent user searches from the database.
    ///
    /// - Parameters:
    ///   - completion: A completion block that receives the result containing either an array of recent user searches or an error.
    public func fetchRecentUserSearches(completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = database.child("users").child("\(uid)/recents").child("users")
        ref.getData { error, snapshot in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists(), let values = snapshot.value as? [String] else {
                    completion(.failure(.empty))
                    return
                }
                completion(.success(values.reversed()))
            }
        }
    }
    
    /// Adds a recently searched message topic for the current user.
    ///
    /// - Parameters:
    ///   - searchedTopic: The topic that was searched for in messages.
    public func addRecentMessageSearches(with searchedTopic: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents").child("messages")

        ref.observeSingleEvent(of: .value) { snapshot in
            if var recentSearches = snapshot.value as? [String] {

                if recentSearches.contains(searchedTopic) {
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
                        return
                    }
                }
            } else {
                ref.setValue([searchedTopic]) { error, _ in
                    if let _ = error {
                        return
                    }
                }
            }
        }
    }
    
    /// Fetches the list of recently searched message topics for the current user.
    ///
    /// - Parameter completion: A closure to be executed when the fetch operation completes.
    ///                         It provides a `Result` enum containing either an array of
    ///                         recently searched message topics on success or a `DatabaseError`
    ///                         on failure.
    public func fetchRecentMessageSearches(completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child("\(uid)/recents").child("messages")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(.unknown))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists(), let values = snapshot.value as? [String] else {
                completion(.failure(.empty))
                return
            }

            completion(.success(values.reversed()))
        }
    }
    
    /// Fetches the list of recently searched message topics for the current user.
    ///
    /// - Parameter completion: A closure to be executed when the fetch operation completes.
    ///                         It provides a `Result` enum containing either an array of
    ///                         recently searched message topics on success or a `DatabaseError`
    ///                         on failure.
    public func deleteRecentMessageSearches(completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/recents/messages")
        
        ref.removeValue { error, _ in
            if let _ = error {
                completion(.unknown)
                return
            }
            completion(nil)
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
    
    /// Add a recent comment to the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the comment.
    ///   - referenceId: The identifier of the reference this comment is related to.
    ///   - commentId: The optional identifier of the parent comment if this is a reply.
    ///   - kind: The kind of the comment (e.g., regular comment or reply).
    ///   - source: The source of the comment (e.g., posts or clinical case).
    ///   - date: The date and time when the comment was created.
    ///   - completion: A closure called when the operation completes. It provides an error if there was any issue.
    public func addRecentComment(withId id: String, withContentId contentId: String, withPath path: [String], kind: CommentKind, source: CommentSource, date: Date, completion: @escaping(DatabaseError?) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/comments").childByAutoId()
        
        let timeInterval = Int(Date().timeIntervalSince1970)
        
        let comment = ["id": id,
                       "kind": kind.rawValue,
                       "contentId": contentId,
                       "path": path,
                       "source": source.rawValue,
                       "timestamp": timeInterval] as [String : Any]
        
        ref.setValue(comment) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Fetches recent comments from the Firebase Realtime Database for a specific user.
    ///
    /// - Parameters:
    ///   - lastTimestampValue: The optional timestamp value to fetch comments before (pagination).
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure called when the operation completes. It provides an array of recent comments or an error.
    public func fetchRecentComments(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[RawComment], DatabaseError>) -> Void) {

        var recentComments = [RawComment]()
        
        let dispatchGroup = DispatchGroup()
        
        if lastTimestampValue == nil {
            let ref = database.child("users").child(uid).child("profile").child("comments").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            
            ref.observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let strongSelf = self else { return }
                
                guard snapshot.exists() else {
                    completion(.failure(.empty))
                    return
                }
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { continue }
                    
                    let recentComment = RawComment(dictionary: value)

                    dispatchGroup.enter()
                    
                    strongSelf.getRecentComments(comment: recentComment) { result in
                        
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        switch result {
                        case .success(let comment):
                            recentComments.append(comment)
                        case .failure(_):
                            completion(.failure(.unknown))
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(.success(recentComments))
                    }
                }
            }
        } else {
            let ref = database.child("users").child(uid).child("profile").child("comments").queryOrdered(byChild: "timestamp").queryEnding(beforeValue: lastTimestampValue).queryLimited(toLast: 10)

            ref.observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let strongSelf = self else { return }
                
                guard snapshot.exists() else {
                    completion(.failure(.empty))
                    return
                }
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { continue }
                    
                    let recentComment = RawComment(dictionary: value)
                    
                    dispatchGroup.enter()
                    
                    strongSelf.getRecentComments(comment: recentComment) { result in
                        
                        defer {
                               dispatchGroup.leave()
                        }
                        
                        switch result {
                        case .success(let comment):
                            recentComments.append(comment)
                        case .failure(_):
                            completion(.failure(.unknown))
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(recentComments))
                }
            }
        }
    }
    
    /// Fetches the detailed information of a recent comment based on the provided `BaseComment`.
    ///
    /// - Parameters:
    ///   - comment: The `BaseComment` for which to fetch detailed information.
    ///   - completion: A completion handler to be called once the operation is complete. The result
    ///                 will contain the updated `BaseComment` with detailed comment information on success,
    ///                 or a `DatabaseError` on failure.
    private func getRecentComments(comment: RawComment, completion: @escaping(Result<RawComment, DatabaseError>) -> Void) {
        var auxComment = comment
        switch comment.source {
        case .post:
            switch comment.kind {
            case .comment:
                let ref = COLLECTION_POSTS.document(comment.contentId).collection("comments").document(comment.id)
                
                ref.getDocument { snapshot, error in

                    if let _ = error {
                        completion(.failure(.unknown))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.failure(.empty))
                            return
                        }
                        
                        let userComment = Comment(dictionary: data)
                        auxComment.setComment(userComment.comment)
                        completion(.success(auxComment))
                    }
                }
            case .reply:
                // Post & Reply
                var ref = COLLECTION_POSTS.document(comment.contentId).collection("comments")
                
                for id in comment.path {
                    ref = ref.document(id).collection("comments")
                }
                
                let commentRef = ref.document(comment.id)

                commentRef.getDocument { snapshot, error in

                    if let _ = error {
                        completion(.failure(.unknown))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.failure(.empty))
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
                let ref = COLLECTION_CASES.document(comment.contentId).collection("comments").document(comment.id)
                
                ref.getDocument { snapshot, error in
                    if let _ = error {
                        completion(.failure(.unknown))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.failure(.empty))
                            return
                        }
                        
                        let userComment = Comment(dictionary: data)
                        auxComment.setComment(userComment.comment)
                        completion(.success(auxComment))
                    }
                }
            case .reply:
                // Case & Reply
                var ref = COLLECTION_CASES.document(comment.contentId).collection("comments")
                
                for id in comment.path {
                    ref = ref.document(id).collection("comments")
                }
                
                let commentRef = ref.document(comment.id)

                commentRef.getDocument { snapshot, error in
                    
                    if let _ = error {
                        completion(.failure(.unknown))
                    } else {
                        guard let snapshot = snapshot, let data = snapshot.data() else {
                            completion(.failure(.empty))
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
    
    /// Delete a recent comment from the Firebase Realtime Database based on its comment ID.
    ///
    /// - Parameters:
    ///   - commentId: The unique identifier of the comment to be deleted.
    ///   - completion: A closure called when the operation completes. It provides an error if there was any issue.
    public func deleteRecentComment(forCommentId commentId: String, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("comments")
        let query = ref.queryOrdered(byChild: "id").queryEqual(toValue: commentId).queryLimited(toFirst: 1)
        
        query.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                if let key = value.keys.first {
                    ref.child(key).removeValue()
                    completion(nil)
                } else {
                    completion(.unknown)
                }
            } else {
                completion(.unknown)
            }
        }
    }
}

//MARK: - User Recent Posts

extension DatabaseManager {
    
    /// Add a recent post to the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the post.
    ///   - date: The date and time when the post was created.
    ///   - completion: A closure called when the operation completes. It provides an error if there was any issue.
    public func addRecentPost(withId id: String, withDate date: Date, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/posts/\(id)/timestamp")
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        ref.setValue(timestamp) { error, _ in
            if let _ = error {
                completion(.unknown)
            }
            completion(nil)
        }
    }
    
    /// Deletes a recent post from the user's profile in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the post to be deleted.
    ///   - completion: A closure that will be called after the delete operation is attempted.
    ///                 If the operation is successful, the completion will be called with `nil`.
    ///                 If an error occurs during the operation, the completion will be called with an appropriate `DatabaseError`.
    public func deleteRecentPost(withId id: String, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child(uid).child("profile").child("posts").child(id)
        ref.removeValue { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Deletes a recent case from the user's profile in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the case to be deleted.
    ///   - completion: A closure that will be called after the delete operation is attempted.
    ///                 If the operation is successful, the completion will be called with `nil`.
    ///                 If an error occurs during the operation, the completion will be called with an appropriate `DatabaseError`.
    public func deleteRecentCase(withId id: String, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users").child(uid).child("profile").child("cases").child(id)
        ref.removeValue { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Get the IDs of recent posts for a specific user from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure called when the operation completes. It provides an array of recent post IDs or an error.
    public func getRecentPostIds(forUid uid: String, completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }

        let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        
        let group = DispatchGroup()
        var postIds = [String]()

        group.enter()
        ref.observeSingleEvent(of: .value) { snapshot in

            guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                completion(.failure(.empty))
                return
            }

            for value in values {
                postIds.append(value.key)
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(.success(postIds))
        }
    }
    
    /// Fetches home feed post IDs for a specific user from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - lastTimestampValue: The optional timestamp value to fetch posts before (pagination).
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure called when the operation completes. It provides an array of post IDs or an error.
    public func fetchHomeFeedPosts(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastTimestampValue == nil {
            let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            ref.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                    completion(.failure(.unknown))
                    return
                }
                let postIds = values.map { $0.key }
                completion(.success(postIds))
            }
        } else {
            let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryEnding(beforeValue: lastTimestampValue).queryLimited(toLast: 10)

            ref.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                    completion(.failure(.unknown))
                    return
                }
                let postIds = values.map { $0.key }
                completion(.success(postIds))
            }
        }
    } 
}

//MARK: - Report Posts & Cases

extension DatabaseManager {
    
    /// Report content using the provided report information and source.
    ///
    /// - Parameters:
    ///   - viewModel: The viewModle of the report.
    ///   - completion: A closure called when the reporting operation completes. It provides an error if there was any issue.
    public func report(viewModel: ReportViewModel, completion: @escaping(DatabaseError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let target = viewModel.target, let topic = viewModel.topic else {
            completion(.unknown)
            return
        }
        
        var reportData = ["contentUid": viewModel.contentUid,
                          "target": target.rawValue,
                          "topic": topic.rawValue,
                          "uid": viewModel.uid] as [String : Any]
        
        if let content = viewModel.content {
            reportData["content"] = content
        }
        
        let ref = database.child("reports").child(String(viewModel.source.rawValue)).child(viewModel.contentId).childByAutoId()
        ref.setValue(reportData) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
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

//MARK: - Patents

extension DatabaseManager {
    
    //MARK: - Write Operations
    
    /// Adds a patent to the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `PatentViewModel` containing the patent details to be added.
    ///   - completion: A closure that will be called once the patent is added or an error occurs.
    ///                 The closure receives a `Result` object with the created `Patent` on success
    ///                 and a `DatabaseError` on failure.
    public func addPatent(viewModel: PatentViewModel, completion: @escaping(Result<Patent, DatabaseError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let title = viewModel.title,
              let code = viewModel.code,
              let uids = viewModel.uids else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("patents").childByAutoId()
        
        let data = ["id": ref.key as Any,
                    "title": title,
                    "code": code,
                    "uids": uids] as [String : Any]
        
        ref.setValue(data) { [weak self] error, reference in
            guard let _ = self else { return }
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                let patent = Patent(dictionary: data)
                completion(.success(patent))
            }
        }
    }
    
    /// Edits an existing patent in the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `PatentViewModel` containing the updated patent details and the patent's ID.
    ///   - completion: A closure that will be called once the patent is updated or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func editPatent(viewModel: PatentViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let id = viewModel.id,
              let title = viewModel.title,
              let code = viewModel.code,
              let uids = viewModel.uids else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("patents").child(id)
        
        let data = ["id": ref.key as Any,
                    "title": title,
                    "code": code,
                    "uids": uids] as [String : Any]
        
        ref.updateChildValues(data) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    
    //MARK: - Fetch Operations
    
    /// Fetches a list of patents from the Firebase Realtime Database for the given user ID.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which to fetch the patents.
    ///   - completion: A closure that will be called once the patents are fetched or an error occurs.
    ///                 The closure receives a `Result` object with an array of `Patent` objects on success
    ///                 and a `DatabaseError` on failure.
    public func fetchPatents(forUid uid: String, completion: @escaping(Result<[Patent], DatabaseError>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("sections").child("patents").queryLimited(toFirst: 3)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let _ = self else { return }
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.failure(.empty))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var patents = [Patent]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                dispatchGroup.enter()
                
                guard let value = child.value as? [String: Any] else {
                    dispatchGroup.leave()
                    return
                }
                
                let patent = Patent(dictionary: value)
                patents.append(patent)
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(patents))
            }
        }
    }
    
    //MARK: - Delete Operations
    
    /// Deletes an existing patent from the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `PatentViewModel` containing the patent's unique identifier (id).
    ///   - completion: A closure that will be called once the patent is deleted or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func deletePatent(viewModel: PatentViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let id = viewModel.id else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("patents").child(id)
        ref.removeValue { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - Publication

extension DatabaseManager {
    
    //MARK: - Write Operations
    
    /// Adds a publication to the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `PublicationViewModel` containing the publication details to be added.
    ///   - completion: A closure that will be called once the publication is added or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func addPublication(viewModel: PublicationViewModel, completion: @escaping(Result<Publication, DatabaseError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let title = viewModel.title,
              let url = viewModel.url,
              let timestamp = viewModel.timestamp,
              let uids = viewModel.uids else {
            completion(.failure(.unknown))
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("publications").childByAutoId()
        
        let data = ["id": ref.key as Any,
                    "title": title,
                    "url": url,
                    "timestamp": timestamp,
                    "uids": uids] as [String : Any]
        
        ref.setValue(data) { [weak self] error, reference in
            guard let _ = self else { return }
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                let publication = Publication(dictionary: data)
                completion(.success(publication))
            }
        }
    }
    
    /// Edits an existing publication in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - viewModel: The `PublicationViewModel` containing the updated publication details and the publication's ID.
    ///   - completion: A closure that will be called once the publication is updated or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func editPublication(viewModel: PublicationViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let id = viewModel.id,
              let title = viewModel.title,
              let url = viewModel.url,
              let timestamp = viewModel.timestamp,
              let uids = viewModel.uids else {
            completion(.unknown)
            return
        }
        
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("publications").child(id)
        
        let data = ["title": title,
                    "url": url,
                    "timestamp": timestamp,
                    "uids": uids] as [String : Any]
        
        ref.updateChildValues(data) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }

    //MARK: - Fetch Operations

    /// Fetches publications from the Firebase Realtime Database for a given user.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which to fetch the publications.
    ///   - completion: A closure that will be called once the publications are retrieved or an error occurs.
    ///                 The closure receives a `Result` object with an array of `Publication` objects on success
    ///                 and a `DatabaseError` on failure.
    public func fetchPublications(forUid uid: String, completion: @escaping(Result<[Publication], DatabaseError>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("sections").child("publications").queryLimited(toFirst: 3)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let _ = self else { return }
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.failure(.empty))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var publications = [Publication]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                dispatchGroup.enter()
                
                guard let value = child.value as? [String: Any] else {
                    dispatchGroup.leave()
                    return
                }
                
                let publication = Publication(dictionary: value)
                publications.append(publication)
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(publications))
            }
        }
    }
    
   
    //MARK: - Delete Operations
    
    /// Deletes an existing publication from the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `PublicationViewModel` containing the publication's unique identifier (id).
    ///   - completion: A closure that will be called once the publication is deleted or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func deletePublication(viewModel: PublicationViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let id = viewModel.id else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("publications").child(id)
        ref.removeValue { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - Education

extension DatabaseManager {
    
    //MARK: - Write Operations
    
    /// Adds an education entry to the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `EducationViewModel` containing the education details.
    ///   - completion: A closure that will be called once the education entry is added or an error occurs.
    ///                 The closure receives a `Result` object with the added `Education` object on success
    ///                 and a `DatabaseError` on failure.
    public func addEducation(viewModel: EducationViewModel, completion: @escaping(Result<Education, DatabaseError>) -> Void) {
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let school = viewModel.school,
              let kind = viewModel.kind,
              let field = viewModel.field,
              let start = viewModel.start else {
            completion(.failure(.unknown))
            return
        }

        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("education").childByAutoId()
        
        var data = ["id": ref.key as Any,
                    "school": school,
                    "kind": kind,
                    "field": field,
                    "start": start] as [String : Any]
        
        if let end = viewModel.end {
            data["end"] = end
        }
        
        ref.setValue(data) { [weak self] error, reference in
            guard let _ = self else { return }
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                let education = Education(dictionary: data)
                completion(.success(education))
            }
        }
    }
    
    //MARK: - Fetch Operations
    
    /// Fetches education entries from the Firebase Realtime Database for a specific user.
    ///
    /// - Parameters:
    ///   - uid: The user ID for which to fetch education entries.
    ///   - completion: A closure that will be called once the education entries are retrieved or an error occurs.
    ///                 The closure receives a `Result` object with an array of `Education` objects on success
    ///                 and a `DatabaseError` on failure.
    public func fetchEducation(forUid uid: String, completion: @escaping(Result<[Education], DatabaseError>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("sections").child("education").queryLimited(toFirst: 3)
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let _ = self else { return }
            
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.failure(.empty))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var educations = [Education]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                dispatchGroup.enter()
                
                guard let value = child.value as? [String: Any] else {
                    dispatchGroup.leave()
                    return
                }
                
                let education = Education(dictionary: value)
                educations.append(education)
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(educations))
            }
        }
    }
    
    /// Updates an existing education entry in the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `EducationViewModel` containing the updated education details.
    ///   - completion: A closure that will be called once the education entry is updated or an error occurs.
    ///                 The closure receives a `DatabaseError` parameter if an error occurs, otherwise `nil`.
    public func editEducation(viewModel: EducationViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let id = viewModel.id,
              let school = viewModel.school,
              let kind = viewModel.kind,
              let field = viewModel.field,
              let start = viewModel.start else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("education").child(id)
        
        var data = ["id": ref.key as Any,
                    "school": school,
                    "kind": kind,
                    "field": field,
                    "start": start] as [String : Any]
        
        if let end = viewModel.end {
            data["end"] = end
        }
        
        ref.setValue(data) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK: - Delete Operations
    
    /// Deletes an education entry from the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `EducationViewModel` containing the ID of the education entry to be deleted.
    ///   - completion: A closure that will be called once the education entry is deleted or an error occurs.
    ///                 The closure receives a `DatabaseError` parameter if an error occurs, otherwise `nil`.
    public func deleteEducation(viewModel: EducationViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let id = viewModel.id else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("education").child(id)
        ref.removeValue { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}


//MARK: - Experience

extension DatabaseManager {
    
    //MARK: - Write Operations
    
    /// Adds a work experience to the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `ExperienceViewModel` containing the work experience details to be added.
    ///   - completion: A closure that will be called once the experience is added or an error occurs.
    ///                 The closure receives a `Result` object with the created `Experience` on success
    ///                 and a `DatabaseError` on failure.
    public func addExperience(viewModel: ExperienceViewModel, completion: @escaping(Result<Experience, DatabaseError>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let role = viewModel.role,
              let company = viewModel.company,
              let start = viewModel.start else {
            completion(.failure(.unknown))
            return
        }
        
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("experiences").childByAutoId()
        
        var data = ["id": ref.key as Any,
                    "role": role,
                    "company": company,
                    "start": start] as [String : Any]
        
        if let end = viewModel.end {
            data["end"] = end
        }
        
        ref.setValue(data) { [weak self] error, reference in
            guard let _ = self else { return }
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                let experience = Experience(dictionary: data)
                completion(.success(experience))
            }
        }
    }
    
    /// Updates an existing work experience in the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `ExperienceViewModel` containing the updated work experience details.
    ///   - completion: A closure that will be called once the experience is updated or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func editExperience(viewModel: ExperienceViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String,
              let id = viewModel.id,
              let role = viewModel.role,
              let company = viewModel.company,
              let start = viewModel.start else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("experiences").child(id)
        
        var data = ["id": id,
                    "role": role,
                    "company": company,
                    "start": start] as [String : Any]
        
        if let end = viewModel.end {
            data["end"] = end
        }
            
        ref.setValue(data) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK: - Fetch Operations
    
    /// Retrieves the work experiences of a specific user from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user whose experiences are to be fetched.
    ///   - completion: A closure that will be called once the experiences are retrieved or an error occurs.
    ///                 The closure receives a `Result` object with an array of `Experience` objects on success
    ///                 and a `DatabaseError` on failure.
    public func fetchExperience(forUid uid: String, completion: @escaping(Result<[Experience], DatabaseError>) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("sections").child("experiences").queryLimited(toFirst: 3)
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let _ = self else { return }
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.failure(.empty))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var experiences = [Experience]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                dispatchGroup.enter()
                
                guard let value = child.value as? [String: Any] else {
                    dispatchGroup.leave()
                    return
                }
                
                let experience = Experience(dictionary: value)
                experiences.append(experience)
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(experiences))
            }
        }
    }

    /// Removes a specific work experience entry from the Firebase Realtime Database for the current user.
    ///
    /// - Parameters:
    ///   - viewModel: The `ExperienceViewModel` containing the ID of the experience to be deleted.
    ///   - completion: A closure that will be called once the experience is removed or an error occurs.
    ///                 The closure receives a `DatabaseError` on failure or `nil` on success.
    public func deleteExperience(viewModel: ExperienceViewModel, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let id = viewModel.id else {
            completion(.unknown)
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid).child("profile").child("sections").child("experiences").child(id)
        ref.removeValue { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}
//MARK: - User Recent Cases

extension DatabaseManager {
    
    /// Add a recent case with a specified case ID to the Firebase Realtime Database.
    ///
    /// - Parameter caseId: The unique identifier for the case to be added.
    public func addRecentCase(withCaseId caseId: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("cases").child(caseId).child("timestamp")
        
        let timestamp = Int(Date().timeIntervalSince1970)

        ref.setValue(timestamp)
    }
    
    /// Get the IDs of recent cases for a specific user from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure called when the operation completes. It provides an array of recent case IDs or an error.
    public func getRecentCaseIds(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastTimestampValue == nil {
            let ref = database.child("users").child(uid).child("profile").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            ref.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                    completion(.failure(.unknown))
                    return
                }
                let caseIds = values.map { $0.key }
                completion(.success(caseIds))
            }
        } else {
            let ref = database.child("users").child(uid).child("profile").child("cases").queryOrdered(byChild: "timestamp").queryEnding(beforeValue: lastTimestampValue).queryLimited(toLast: 10)

            ref.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                    completion(.failure(.unknown))
                    return
                }
                let caseIds = values.map { $0.key }
                completion(.success(caseIds))
            }
        }
    }
    
    
    /// Check if a user has more than three visible cases in their profile.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure called when the operation completes. It provides the count of visible cases.
    public func checkIfUserHasMoreThanThreeVisibleCases(forUid uid: String, completion: @escaping(Int) -> Void) {
        let ref = database.child("users").child(uid).child("profile").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        ref.observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                completion(0)
                return
            }
            
            completion(values.count)
        }
    }
}

// MARK: - Notifications Manager

extension DatabaseManager {
    
    /// Add a notification token to the database for the authenticated user.
    ///
    /// - Parameter tokenID: The notification token to be added.
    func addNotificationToken(tokenID: String) {
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("tokens").child(uid)
            ref.setValue(tokenID)
        }
    }
    
    /// Remove a notification token from the database for a specific user.
    ///
    /// - Parameter uid: The unique identifier of the user for whom the token will be removed.
    func removeNotificationToken(for uid: String) {
        let ref = Database.database().reference().child("tokens").child(uid)
        ref.removeValue()
    }
}

//MARK: - Sending messages & Conversations

extension DatabaseManager {
    
    /// Create a new conversation with an initial message in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversation: The conversation object representing the conversation.
    ///   - message: The initial message to be added to the conversation.
    ///   - completion: A closure called when the operation completes. It provides an error if there was any issue.
    public func createNewConversation(_ conversation: Conversation, with message: Message, completion: @escaping(DatabaseError?) -> Void) {
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
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Delete a conversation from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversation: The conversation object representing the conversation to be deleted.
    ///   - completion: A closure called when the operation completes. It provides an error if there was any issue.
    public func deleteConversation(_ conversation: Conversation, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let id = conversation.id else {
            return
        }
        let ref = database.child("users/\(uid)/conversations/\(id)")
        ref.removeValue { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Fetch messages for a list of conversations from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversations: The list of conversation objects for which messages need to be fetched.
    ///   - completion: A closure called when the fetching operation completes. It provides an error if there was any issue.
    public func fetchMessages(for conversations: [Conversation], completion: @escaping(DatabaseError?) -> Void) {
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

                newMessages.sort(by: { $0.sentDate > $1.sentDate })
                DataService.shared.save(conversation: conversation, latestMessage: newMessages.removeFirst())
                
                for newMessage in newMessages {
                    DataService.shared.save(message: newMessage, to: conversation)
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(nil)
        }
    }
    
    /// Toggle the synchronization status for a list of conversations in the Firebase Realtime Database.
    ///
    /// - Parameter conversations: The list of conversation objects for which synchronization status needs to be toggled.
    public func toggleSync(for conversations: [Conversation]) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        for conversation in conversations {
            guard let id = conversation.id else {
                continue
            }
            let ref = database.child("users/\(uid)/conversations/\(id)/sync")
            ref.setValue(true)
            
        }
    }
    
    /// Send a message to a conversation and store it in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversation: The conversation object to which the message will be sent.
    ///   - message: The message to be sent.
    ///   - completion: A closure called when the sending operation completes. It provides an error if there was any issue.
    public func sendMessage(to conversation: Conversation, with message: Message, completion: @escaping(DatabaseError?) -> Void) {
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
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Observe new messages on a list of conversations in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversations: The list of conversation objects for which new messages need to be observed.
    ///   - completion: A closure called when new messages are observed. It provides the conversation ID of the conversation with new messages.
    public func observeNewMessages(on conversations: [Conversation], completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        _ = conversations.map { $0.id! }
        
        for conversation in conversations {
            guard let conversationId = conversation.id, let _ = conversation.latestMessage else { return }

            let ref = database.child("users/\(uid)/conversations/\(conversationId)").queryOrdered(byChild: "sync").queryEqual(toValue: true)
            ref.observe(.value) { snapshot in
                
                guard snapshot.exists() else {
                    return
                }
                
                guard let sync = snapshot.childSnapshot(forPath: "sync").value as? Bool, !sync else { return }
                if let latestMessage = snapshot.childSnapshot(forPath: "latestMessage").value as? String {
                    self.fetchMessage(withId: latestMessage, for: conversationId) { error in
                        if let _ = error {
                            return
                        } else {
                            completion(conversationId)
                        }
                    }
                }
            }
        }
    }
    
    /// Observe new messages in a conversation in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversation: The conversation object for which new messages need to be observed.
    ///   - completion: A closure called when new messages are observed. It provides the observed message.
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
    
    /// Fetch a specific message from a conversation in the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - messageId: The ID of the message to fetch.
    ///   - conversationId: The ID of the conversation from which the message should be fetched.
    ///   - completion: A closure called when the fetching operation completes. It provides an error if there was any issue.
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
            
            if newMessage.image != nil {
                FileGateway.shared.saveImage(url: newMessage.image, userId: newMessage.messageId) { url in
                    if let url = url {
                        newMessage.updateImage(url.absoluteString)
                        DataService.shared.save(message: newMessage, to: conversationId)
                        completion(nil)
                    }
                }
            } else {
                DataService.shared.save(message: newMessage, to: conversationId)
                completion(nil)
            }
        }
    }
    
    /// Observe conversations in the Firebase Realtime Database.
    ///
    /// - Parameter completion: A closure called when new conversations are observed. It provides the conversation ID of the observed conversation.
    public func observeConversations(completion: @escaping(String) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let ref = database.child("users/\(uid)/conversations").queryOrdered(byChild: "sync").queryEqual(toValue: false)
        ref.observe(.value) { snapshot in

            guard snapshot.exists() else {
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else {
                    return
                }
                
                guard let userId = child.childSnapshot(forPath: "userId").value as? String else { return }
                let conversationId = child.key
                
                DataService.shared.conversationExists(for: userId) { exists in
                    if exists {
                        if let conversation = DataService.shared.getConversation(with: conversationId) {
                            self.fetchMessages(for: conversation) { error in
                                if let _ = error {
                                    return
                                } else {
                                    completion(conversationId)
                                }
                            }
                        }
                    } else {
                        guard let timeInterval = value["date"] as? TimeInterval else {
                            return
                        }
                        let date = Date(timeIntervalSince1970: timeInterval)
                        
                        UserService.fetchUser(withUid: userId) { result in
                            
                            switch result {
                            case .success(let user):

                                FileGateway.shared.saveImage(url: user.profileUrl, userId: userId) { [weak self] url in
                                    guard let strongSelf = self else { return }
                                    let name = user.firstName! + " " + user.lastName!
                                    let conversation = Conversation(id: conversationId, userId: userId, name: name, date: date, image: url?.absoluteString ?? nil)
                                    
                                    strongSelf.fetchMessages(forNewConversation: conversation) { error in
                                        if let _ = error {
                                            return
                                        } else {
                                            completion(conversationId)
                                        }
                                    }
                                }
                            case .failure(_):
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Fetch new messages for a conversation from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - conversation: The conversation for which new messages need to be fetched.
    ///   - completion: A closure called when the fetching operation completes. It provides an error if there was any issue.
    public func fetchMessages(for conversation: Conversation, completion: @escaping(DatabaseError?) -> Void) {
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

                return
            }
            
            guard let messages = snapshot.value as? [String: [String: Any]] else {

                return
            }

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

            newMessages.sort(by: { $0.sentDate < $1.sentDate })

            for newMessage in newMessages {
                group.enter()

                DataService.shared.save(message: newMessage, to: conversation)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.toggleSync(for: [conversation])
            completion(nil)
        }
    }
    
    /// Fetches messages for a new conversation.
    ///
    /// - Parameters:
    ///   - conversation: The conversation for which to fetch messages.
    ///   - completion: A closure that gets called when the fetch operation completes.
    ///                 If an error occurs during the fetch, the `DatabaseError` will be non-nil.
    public func fetchMessages(forNewConversation conversation: Conversation, completion: @escaping(DatabaseError?) -> Void) {
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

            DataService.shared.save(conversation: conversation, latestMessage: newMessages.removeFirst())
            for newMessage in newMessages {
                group.enter()
                DataService.shared.save(message: newMessage, to: conversation)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.toggleSync(for: [conversation])
            completion(nil)
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
                    completion(.failure(.empty))
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

extension DatabaseManager {
    public func fetchWebsite(forUid uid: String, completion: @escaping(Result<String, DatabaseError>) -> Void) {
        let ref = database.child("users").child("\(uid)/profile/sections/website")
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        ref.getData { error, snapshot in
            
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                guard let snapshot = snapshot, snapshot.exists() else {
                    completion(.failure(.empty))
                    return
                }
                
                if let website = snapshot.value as? String {
                    completion(.success(website))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    public func addWebsite(withUrl url: String, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/sections/website")
        ref.setValue(url) { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}
