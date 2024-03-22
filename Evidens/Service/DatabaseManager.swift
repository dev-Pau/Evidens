//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import Firebase
import FirebaseDatabase

/// Manager object to read and write data to real time firebase database.
final class DatabaseManager {
    
    /// Shared instance of class
    public static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

// MARK: - Comment Operations

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
    public func addRecentComment(on commentUid: String, withId id: String, withContentId contentId: String, withPath path: [String], kind: CommentKind, source: CommentSource, date: Date, completion: @escaping(DatabaseError?) -> Void) {
        
        guard let uid = UserDefaults.getUid() else { return }
        let ref = database.child("users").child("\(uid)/profile/comments").childByAutoId()
        
        let timeInterval = Int(Date().timeIntervalSince1970)
        
        let comment = ["uid": commentUid,
                       "id": id,
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
    public func fetchRecentComments(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[ProfileComment], DatabaseError>) -> Void) {

        var recentComments = [ProfileComment]()
        
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
                    
                    let recentComment = ProfileComment(dictionary: value)

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
                        recentComments.sort(by: { $0.timestamp > $1.timestamp })
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
                    
                    let recentComment = ProfileComment(dictionary: value)
                    
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
                    recentComments.sort(by: { $0.timestamp > $1.timestamp })
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
    private func getRecentComments(comment: ProfileComment, completion: @escaping(Result<ProfileComment, DatabaseError>) -> Void) {
        var auxComment = comment
        switch comment.source {
        case .post:
            switch comment.kind {
            case .comment:
                let ref = K.FirestoreCollections.COLLECTION_POSTS.document(comment.contentId).collection("comments").document(comment.id)
                
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

                var ref = K.FirestoreCollections.COLLECTION_POSTS.document(comment.contentId).collection("comments")
                
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

                let ref = K.FirestoreCollections.COLLECTION_CASES.document(comment.contentId).collection("comments").document(comment.id)
                
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

                var ref = K.FirestoreCollections.COLLECTION_CASES.document(comment.contentId).collection("comments")
                
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
        guard let uid = UserDefaults.getUid() else { return }
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
        guard let uid = UserDefaults.getUid() else { return }
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
        guard let uid = UserDefaults.getUid() else { return }
        
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
        guard let uid = UserDefaults.getUid() else { return }
        
        let ref = database.child("users").child(uid).child("profile").child("cases").child(id)
        ref.removeValue { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }

    /// Fetches home feed post IDs for a specific user from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - lastTimestampValue: The optional timestamp value to fetch posts before (pagination).
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure called when the operation completes. It provides an array of post IDs or an error.
    public func getUserPosts(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        
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
        
        var reportData = ["userId": viewModel.userId,
                          "target": target.rawValue,
                          "topic": topic.rawValue,
                          "uid": viewModel.uid] as [String : Any]
        
        if let content = viewModel.content {
            reportData["content"] = content
        }
        
        let ref = database.child("reports").child(String(viewModel.source.name)).child(viewModel.contentId).childByAutoId()
        ref.setValue(reportData) { error, reference in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - User Draft Cases

extension DatabaseManager {
    
    /// Get the IDs of draft cases from the Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - lastTimestampValue: The last timestamp for pagination purposes.
    ///   - completion: A closure called when the operation completes. It provides an array of draft case IDs or an error.
    public func getDraftCases(lastTimestampValue: Int64?, completion: @escaping(Result<[String], DatabaseError>) -> Void) {
        guard let uid = UserDefaults.getUid() else { return }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        if lastTimestampValue == nil {
            let ref = database.child("users").child(uid).child("drafts").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            
            ref.observeSingleEvent(of: .value) { snapshot in
                
                guard snapshot.exists(), let values = snapshot.value as? [String: Any] else {
                    completion(.failure(.unknown))
                    return
                }
                
                let caseIds = values.map { $0.key }
                completion(.success(caseIds))
            }
        } else {
            let ref = database.child("users").child(uid).child("drafts").child("cases").queryOrdered(byChild: "timestamp").queryEnding(beforeValue: lastTimestampValue).queryLimited(toLast: 10)
            
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
}

//MARK: - User Recent Cases

extension DatabaseManager {
    
    /// Add a recent case with a specified case ID to the Firebase Realtime Database.
    ///
    /// - Parameter caseId: The unique identifier for the case to be added.
    public func addRecentCase(withCaseId caseId: String) {
        guard let uid = UserDefaults.getUid() else { return }
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
        guard let uid = UserDefaults.getUid() else { return }
        let ref = database.child("users").child("\(uid)/profile/sections/about")
        
        let trimAbout = aboutText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        ref.setValue(trimAbout) { error, _ in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
}

//MARK: - Fetch Operations
extension DatabaseManager {
    
    /// Fetches the website information for a user from the database.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier of the user.
    ///   - completion: A closure to be executed once the operation is completed, containing the result.
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
    
    /// Adds a website URL to the user's profile section in the database.
    ///
    /// - Parameters:
    ///   - url: The website URL to be added.
    ///   - completion: A closure to be executed once the operation is completed, indicating the result.
    public func addWebsite(withUrl url: String, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.getUid() else { return }
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
