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
    
   
    /// Inserts new user to database with a ChatUser struct
    /// Parameters:
    /// - `user`:   Target user to be inserted to database
    public func insertUser(with user: ChatUser, completion: @escaping(Bool) -> Void) {
        //Create user entry based on UID
        let userData = ["firstName": user.firstName.capitalized,
                        "lastName": user.lastName.capitalized,
                        "emailAddress": user.emailAddress,
                        "helpers": ["home": true]] as [String : Any]
        /*
        database.child("users").child(user.uid).setValue(["firstName": user.firstName.capitalized,
                                                          "lastName": user.lastName.capitalized,
                                                          "emailAddress": user.emailAddress,
                                                          "helpers": ["home": true]])
        */
        database.child("users").child(user.uid).setValue(userData) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    
    public func insert(user: User, completion: @escaping(DatabaseError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(.network)
            return
        }
        
        let ref = database.child("users").child(uid)
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
                        auxComment.setComment(userComment.commentText)
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
                        auxComment.setComment(userComment.commentText)
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
                        auxComment.setComment(userComment.commentText)
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
                        auxComment.setComment(userComment.commentText)
                        completion(.success(auxComment))
                    }
                }
            }
        }
    }
    
    public func deleteRecentComment(forCommentId commentID: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("comments")
        let query = ref.queryOrdered(byChild: "id").queryEqual(toValue: commentID).queryLimited(toFirst: 1)
        
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
    
    public func fetchHomeFeedPosts(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        
        var uids: [String] = []
        
        if lastTimestampValue == nil {
            // First group to fetch
            let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        uids.append(value.key)
                        if uids.count == snapshot.children.allObjects.count {
                            completion(.success(uids))
                            return
                        }
                    }
                } else {
                    completion(.success([]))
                }
            }
            
        } else {
            // Fetch more posts
            let ref = database.child("users").child(uid).child("profile").child("posts").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            
            //queryStarting(afterValue: lastTimestampValue).queryLimited(toFirst: 1)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        uids.append(value.key)
                        if uids.count == snapshot.children.allObjects.count {
                            completion(.success(uids))
                            return
                        }
                    }
                } else {
                    completion(.success([]))
                }
            }
        }
    } 
}

//MARK: - Report Posts & Cases

extension DatabaseManager {
    
    public func reportContent(source: ReportSource, report: Report, completion: @escaping(Bool) -> Void) {
        var reportData = ["contentOwnerUid": report.contentOwnerUid,
                          "target": report.target.rawValue,
                          "topic": report.topic.rawValue,
                          "reportOwnerUid": report.reportOwnerUid] as [String : Any]
        
        if let reportInfo = report.reportInfo {
            reportData["reportInfo"] = reportInfo
        }
        
        let ref = database.child("reports").child(String(source.rawValue)).child(report.contentId).childByAutoId()
        ref.setValue(reportData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
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
    
    public func reportCase(forUid caseUid: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
        let ref = database.child("reports").child("cases").child(caseUid).childByAutoId()
        let reportData = ["uid": uid]
        ref.setValue(reportData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func reportCaseComment(forCommentId commentID: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
        let ref = database.child("reports").child("case_comments").child(commentID).childByAutoId()
        let reportData = ["uid": uid]
        ref.setValue(reportData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func reportPostComment(forCommentId commentID: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") else { return }
        let ref = database.child("reports").child("post_comments").child(commentID).childByAutoId()
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

//MARK: - User Languages

extension DatabaseManager {
    
    public func uploadLanguage(language: Language, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        // Check if language already exists
        let ref = database.child("users").child(uid).child("profile").child("languages").queryOrdered(byChild: "languageName").queryEqual(toValue: language.name)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                // Language is already uploaded by the user
                completion(false)
                return
            }
            
            // New Language. Add Language to user's profile
            let languageData = ["languageName": language.name, "languageProficiency": language.proficiency]
            let newLanguageRef = self.database.child("users").child(uid).child("profile").child("languages").childByAutoId()
            newLanguageRef.setValue(languageData) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    public func fetchLanguages(forUid uid: String, completion: @escaping(Result<[Language], Error>) -> Void) {
        var languageData = [[String: Any]]()
        var recentLanguages = [Language]()
        
        let ref = database.child("users").child(uid).child("profile").child("languages")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.success(recentLanguages))
                return
            }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                languageData.append(value)
                if languageData.count == snapshot.children.allObjects.count {
                    let languages: [Language] = languageData.compactMap { dictionary in
                        guard let name = dictionary["languageName"] as? String,
                              let proficiency = dictionary["languageProficiency"] as? String else { return nil }
                        return Language(name: name, proficiency: proficiency)
                    }
                    completion(.success(languages))
                }
            }
        }
    }



    public func updateLanguage(language: Language, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let ref = database.child("users").child(uid).child("profile").child("languages").queryOrdered(byChild: "languageName").queryEqual(toValue: language.name)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let languageData = ["languageName": language.name, "languageProficiency": language.proficiency]
                
                let newRef = self.database.child("users").child(uid).child("profile").child("languages").child(key)
                newRef.setValue(languageData) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func deleteLanguage(language: Language, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("profile").child("languages").queryOrdered(byChild: "languageName").queryEqual(toValue: language.name)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let newRef = self.database.child("users").child(uid).child("profile").child("languages").child(key)
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

//MARK: - Group Manager

extension DatabaseManager {
    
    public func uploadNewGroup(groupId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("groups").child(groupId).child("users").childByAutoId()
        
        let joiningDateTimestamp = NSDate().timeIntervalSince1970
        
        let ownerUser = ["uid": uid,
                         "timestamp": joiningDateTimestamp,
                         "memberType": 0] as [String : Any]
        
        ref.setValue(ownerUser) { error, _ in
            
            let userRef = self.database.child("users").child(uid).child("groups").childByAutoId()
            
            let newGroup = ["groupId": groupId,
                            "memberType": 0]
            
            userRef.setValue(newGroup) { error, _ in
                if let _ = error {
                    completion(false)
                    return
                }
                
                self.database.child("groups").child(groupId).child("allUsers").setValue(1) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }

            }
        }
    }
    
    public func fetchNumberOfGroupUsers(groupId: String, completion: @escaping(Int) -> Void) {
        let groupRef = self.database.child("groups").child(groupId).child("allUsers")
        groupRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? Int {
                completion(value)
            }
        }
    }
    

    public func sendRequestToGroup(groupId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let userRef = database.child("users").child(uid).child("groups").childByAutoId()
        let joiningDateTimestamp = NSDate().timeIntervalSince1970
        
        let groupData = ["groupId": groupId,
                         "memberType": Group.MemberType.pending.rawValue] as [String : Any]
        
        let joiningUser = ["uid": uid,
                           "timestamp": joiningDateTimestamp,
                           "memberType": Group.MemberType.pending.rawValue] as [String : Any]
        
        userRef.setValue(groupData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            
            let groupRef = self.database.child("groups").child(groupId).child("users").childByAutoId()
            groupRef.setValue(joiningUser) { error, _ in
                if let _ = error {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    public func ignoreUserRequestToGroup(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                self.database.child("users").child(uid).child("groups").child(key).removeValue { error, _ in
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).removeValue { error, _ in
                                if let _ = error {
                                    
                                }
                                
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func removeFromGroup(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                self.database.child("users").child(uid).child("groups").child(key).removeValue { error, _ in
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).removeValue { error, _ in
                                if let _ = error {
                                    
                                }
                                
                                self.database.child("groups").child(groupId).child("allUsers").observeSingleEvent(of: .value) { snapshot in
                                    if let value = snapshot.value as? Int {
                                        self.database.child("groups").child(groupId).child("allUsers").setValue(value - 1) { error, _ in
                                            if let _ = error { return }
            
                                            completion(true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func acceptUserRequestToGroup(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                
                guard let key = value.first?.key else { return }
                self.database.child("users").child(uid).child("groups").child(key).updateChildValues(["memberType": Group.MemberType.member.rawValue]) { error, _ in
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).updateChildValues(["memberType": Group.MemberType.member.rawValue]) { error, _ in
                                
                                self.database.child("groups").child(groupId).child("allUsers").observeSingleEvent(of: .value) { snapshot in
                                    if let value = snapshot.value as? Int {
                                        self.database.child("groups").child(groupId).child("allUsers").setValue(value + 1) { error, _ in
                                            if let _ = error { return }
            
                                            completion(true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func inviteUsersToGroup(groupId: String, uids: [String], completion: @escaping(Bool) -> Void) {
        var usersThatAlreadyExist: Int = 0
        var count = 0
        uids.forEach { uid in

            let existsRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
            existsRef.observeSingleEvent(of: .value) { snapshot in
                count += 1
                
                guard !snapshot.exists() else {
                    if count == uids.count {
                        completion(true)
                        return
                    }
                    print("user is already in the group")
                    return
                }
                
                let groupData = ["groupId": groupId,
                                 "memberType": Group.MemberType.invited.rawValue] as [String : Any]
                
                
                let userRef = self.database.child("users").child(uid).child("groups").childByAutoId()
                userRef.setValue(groupData) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    let groupRef = self.database.child("groups").child(groupId).child("users").childByAutoId()
                    
                    let invitedDateTimestamp = NSDate().timeIntervalSince1970
                    
                    let invitedUser = ["uid": uid,
                                       "timestamp": invitedDateTimestamp,
                                       "memberType": Group.MemberType.invited.rawValue] as [String : Any]
                    
                    groupRef.setValue(invitedUser) { error, _ in
                        if let _ = error {
                            completion(false)
                            return
                        }
                        
                        if count == uids.count {
                            completion(true)
                            return
                        }
                    }
                }
              
                #warning("Enviar notificació al nou usuari")
            }
        }
    }
    
    public func unsendRequestToGroup(groupId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                self.database.child("users").child(uid).child("groups").child(key).removeValue { error, _ in
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).removeValue { error, _ in
                                if let _ = error {
                                    
                                }
                                
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    public func getNumberOfOwnersForGroup(groupId: String, completion: @escaping(Int) -> Void) {
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryEqual(toValue: Group.MemberType.owner.rawValue)
        groupRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            completion(value.count)
        }
    }
    
    public func getNumberOfAdminsForGroup(groupId: String, completion: @escaping(Int) -> Void) {
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryEqual(toValue: Group.MemberType.admin.rawValue)
        groupRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            completion(value.count)
        }
    }
    
    public func removeAdminPermissions(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                self.database.child("users").child(uid).child("groups").child(key).child("memberType").setValue(Group.MemberType.member.rawValue) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).child("memberType").setValue(Group.MemberType.member.rawValue) { error, _ in
                                if let _ = error {
                                    
                                }
                                completion(true)
                            }
                        }
                    }  
                }
            }
        }
    }
    
    public func promoteToOwner(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                self.database.child("users").child(uid).child("groups").child(key).child("memberType").setValue(Group.MemberType.owner.rawValue) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).child("memberType").setValue(Group.MemberType.owner.rawValue) { error, _ in
                                if let _ = error {
                                    
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func promoteToAdmin(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                self.database.child("users").child(uid).child("groups").child(key).child("memberType").setValue(Group.MemberType.admin.rawValue) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).child("memberType").setValue(Group.MemberType.admin.rawValue) { error, _ in
                                if let _ = error {
                                    
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func blockUser(groupId: String, uid: String, completion: @escaping(Bool) -> Void) {
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                self.database.child("users").child(uid).child("groups").child(key).child("memberType").setValue(Group.MemberType.blocked.rawValue) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    let groupRef = self.database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
                    groupRef.observeSingleEvent(of: .value) { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            guard let key = value.first?.key else { return }
                            self.database.child("groups").child(groupId).child("users").child(key).child("memberType").setValue(Group.MemberType.blocked.rawValue) { error, _ in
                                if let _ = error {
                                    
                                }
                                
                                self.database.child("groups").child(groupId).child("allUsers").observeSingleEvent(of: .value) { snapshot in
                                    if let value = snapshot.value as? Int {
                                        self.database.child("groups").child(groupId).child("allUsers").setValue(value - 1) { error, _ in
                                            if let _ = error { return }
            
                                            completion(true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func fetchUserIdMemberTypeGroups(completion: @escaping(Result<[MemberTypeGroup], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var memberTypes = [MemberTypeGroup]()
        
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "memberType").queryStarting(atValue: 0).queryEnding(beforeValue: 3)
        
        userRef.observeSingleEvent(of: .value) { snapshot in

            if !snapshot.exists() {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                let memberType = MemberTypeGroup(dictionary: value)
                memberTypes.append(memberType)
            }
            completion(.success(memberTypes))
        }
    }
    
    public func fetchUserIdPendingGroups(completion: @escaping(Result<[MemberTypeGroup], Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        var memberTypes = [MemberTypeGroup]()
        
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "memberType").queryEqual(toValue: 3)
        
        userRef.observeSingleEvent(of: .value) { snapshot in

            if !snapshot.exists() {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                let memberType = MemberTypeGroup(dictionary: value)
                memberTypes.append(memberType)
            }
            completion(.success(memberTypes))
        }
    }
    
    public func fetchFirstGroupUsers(forGroupId groupId: String, completion: @escaping([String]) -> Void) {
        var uids = [String]()
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryStarting(atValue: 0).queryEnding(atValue: 2).queryLimited(toLast: 3)
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(uids)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any], let uid = value["uid"] as? String else { return }
                uids.append(uid)
                if uids.count == snapshot.children.allObjects.count {
                    completion(uids)
                }
            }
        }
    }
    
    public func fetchGroupUsers(forGroupId groupId: String, completion: @escaping([String]) -> Void) {
        var uids = [String]()
        let groupRef = database.child("groups").child(groupId).queryOrderedByKey()
        groupRef.getData { error, snapshot in
            if let _ = error {
                return
            }
            
            guard let snapshot = snapshot else { return }
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any], let uid = value["uid"] as? String else { return }
                uids.append(uid)
            }
            completion(uids)
        }
    }
    
    public func checkIfUserHasGroups(completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let groupRef = database.child("users").child(uid).child("groups").queryOrderedByKey().queryLimited(toFirst: 1)
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
                return
            }
            
            completion(false)
            return
        }
    }
    
    public func fetchGroupAdminTeamRoles(groupId: String, completion: @escaping([UserGroup]) -> Void) {
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryStarting(atValue: 0).queryEnding(atValue: 1)
        
        var adminUsers = [UserGroup]()
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(adminUsers)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                adminUsers.append(UserGroup(dictionary: value))
                if adminUsers.count == snapshot.children.allObjects.count {
                    completion(adminUsers)
                }
            }
        }
    }
    
    public func fetchGroupMembers(groupId: String, completion: @escaping([UserGroup]) -> Void) {
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryEqual(toValue: Group.MemberType.member.rawValue)
        
        var members = [UserGroup]()
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(members)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                members.append(UserGroup(dictionary: value))
            }
            completion(members)
        }
    }
    
    public func fetchGroupBlocked(groupId: String, completion: @escaping([UserGroup]) -> Void) {
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryEqual(toValue: Group.MemberType.blocked.rawValue)
        
        var members = [UserGroup]()
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(members)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                members.append(UserGroup(dictionary: value))
            }
            completion(members)
        }
    }

    public func fetchGroupInvites(groupId: String, completion: @escaping([UserGroup]) -> Void) {
        
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryEqual(toValue: Group.MemberType.invited.rawValue)
        
        var members = [UserGroup]()
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(members)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                members.append(UserGroup(dictionary: value))
            }
            completion(members)
        }
        
    }
    
    public func fetchGroupUserRequests(groupId: String, completion: @escaping([UserGroup]) -> Void) {
        let groupRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "memberType").queryEqual(toValue: Group.MemberType.pending.rawValue)
        var pendingUsers = [UserGroup]()
        
        groupRef.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                print("snapshot doesnt exist")
                completion(pendingUsers)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                pendingUsers.append(UserGroup(dictionary: value))
            }
            completion(pendingUsers)
        }
    }
    
    public func fetchUserMemberTypeForGroup(groupId: String, completion: @escaping(Group.MemberType) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let userRef = database.child("users").child(uid).child("groups").queryOrdered(byChild: "groupId").queryEqual(toValue: groupId)
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(Group.MemberType.external)
                return
            }
            
            snapshot.children.forEach { child in
                if let child = child as? DataSnapshot, let value = child.value as? [String: Any], let memberType = value["memberType"] as? Int {
                    print(Group.MemberType(rawValue: memberType)!)
                    completion(Group.MemberType(rawValue: memberType)!)
                }
            }
        }
    }
    
    public func uploadRecentPostToGroup(withGroupId groupId: String, withPostId postId: String, withPermission permission: GroupPermission, completion: @escaping (Bool) -> Void) {
        let timestamp = NSDate().timeIntervalSince1970
        
        let data = ["id": postId,
                    "timestamp": timestamp,
                    "type": 1] as [String: Any]
        
        if permission == .review || permission == .all {
            let ref = database.child("groups").child(groupId).child("content").child("review").child("posts").childByAutoId()
            
            ref.setValue(data) { error, _ in
                if let _ = error {
                    completion(false)
                }
                completion(true)
            }
        } else {
            let ref = database.child("groups").child(groupId).child("content").child("all").childByAutoId()
            let groupRef = database.child("groups").child(groupId).child("content").child("posts").child(postId).child("timestamp")
            
            ref.setValue(data) { error, _ in
                if let _ = error {
                    completion(false)
                }
                
                groupRef.setValue(timestamp) { error, _ in
                    if let _ = error {
                        completion(false)
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func uploadRecentCaseToGroup(withGroupId groupId: String, withCaseId caseId: String, withPermission permission: GroupPermission, completion: @escaping(Bool) -> Void) {
        
        let timestamp = NSDate().timeIntervalSince1970
        
        let data = ["id": caseId,
                    "timestamp": timestamp,
                    "type": 0] as [String: Any]
        
        if permission == .review || permission == .all {
            let ref = database.child("groups").child(groupId).child("content").child("review").child("cases").childByAutoId()
            
            ref.setValue(data) { error, _ in
                if let _ = error {
                    completion(false)
                }
                completion(true)
            }
        } else {
            let ref = database.child("groups").child(groupId).child("content").child("all").childByAutoId()
            let groupRef = database.child("groups").child(groupId).child("content").child("cases").child(caseId).child("timestamp")
            
            
            ref.setValue(data) { error, _ in
                if let _ = error {
                    completion(false)
                }
                
                groupRef.setValue(timestamp) { error, _ in
                    if let _ = error {
                        completion(false)
                    }
                    completion(true)
                }
            }
        }
        
    }
    
    public func fetchAllGroupContent(withGroupId groupId: String, lastTimestampValue: Int64?, completion: @escaping([ContentGroup]) -> Void) {
        var recentContent = [ContentGroup]()
        
        if lastTimestampValue == nil {
            let contentRef = database.child("groups").child(groupId).child("content").child("all").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            contentRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(recentContent)
                    return
                }
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    recentContent.append(ContentGroup(dictionary: value))
                    if recentContent.count == snapshot.children.allObjects.count {
                        completion(recentContent.reversed())
                    }
                }
            }
        } else {
            let contentRef = database.child("groups").child(groupId).child("content").child("all").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            contentRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(recentContent)
                    return
                }
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    recentContent.append(ContentGroup(dictionary: value))
                    if recentContent.count == snapshot.children.allObjects.count {
                        completion(recentContent.reversed())
                    }
                }
            }
        }
    }
    
    public func fetchAllGroupPosts(withGroupId groupId: String, lastTimestampValue: Int64?, completion: @escaping([String]) -> Void) {
        var postIds = [String]()
        if lastTimestampValue == nil {
            // Fetch first group posts
            let postsRef = database.child("groups").child(groupId).child("content").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            postsRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(postIds)
                    return
                }
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        postIds.append(value.key)
                        if postIds.count == values.count {
                            completion(postIds)
                        }
                    }
                }
            }
        } else {
            // Fetch more posts
            let postsRef = database.child("groups").child(groupId).child("content").child("posts").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)

            postsRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(postIds)
                    return
                }
                
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        postIds.append(value.key)
                        if postIds.count == values.count {
                            completion(postIds)
                        }
                    }
                }
            }
        }
    }
    
    public func fetchAllGroupCases(withGroupId groupId: String, lastTimestampValue: Int64?, completion: @escaping([String]) -> Void) {
        var caseIds = [String]()
        if lastTimestampValue == nil {
            let casesRef = database.child("groups").child(groupId).child("content").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            casesRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(caseIds)
                    return
                }
                
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        caseIds.append(value.key)
                        if caseIds.count == values.count {
                            completion(caseIds)
                        }
                    }
                }
               
            }
        } else {
            let casesRef = database.child("groups").child(groupId).child("content").child("cases").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            casesRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(caseIds)
                    return
                }
                
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        caseIds.append(value.key)
                        if caseIds.count == values.count {
                            completion(caseIds)
                        }
                    }
                }
            }
        }
    }
    
    public func fetchPendingPostsForGroup(withGroupId groupId: String, completion: @escaping([ContentGroup]) -> Void) {
        var recentContent = [ContentGroup]()
        let postsRef = database.child("groups").child(groupId).child("content").child("review").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        postsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentContent.append(ContentGroup(dictionary: value))
                //recentComments.append(value)
            }
            completion(recentContent.reversed())
        }
    }
    
    public func approveGroupPost(withGroupId groupId: String, withPostId postId: String, completion: @escaping(Bool) -> Void) {
        let postRef = database.child("groups").child(groupId).child("content").child("review").child("posts").queryOrdered(byChild: "id").queryEqual(toValue: postId)
        postRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count == 1 {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    self.database.child("groups").child(groupId).child("content").child("review").child("posts").child(key).removeValue { error, _ in
                        
                        if let error = error {
                            completion(false)
                            return
                        }
                        let ref = self.database.child("groups").child(groupId).child("content").child("all").childByAutoId()
                        let groupRef = self.database.child("groups").child(groupId).child("content").child("posts").child(postId).child("timestamp")
                        
                        let timestamp = NSDate().timeIntervalSince1970
                        
                        let data = ["id": postId,
                                    "timestamp": timestamp,
                                    "type": 1] as [String: Any]
                        
                        
                        
                        ref.setValue(data) { error, _ in
                            if let _ = error {
                                completion(false)
                            }
                            
                            groupRef.setValue(timestamp) { error, _ in
                                if let _ = error {
                                    completion(false)
                                }
                                completion(true)
                            }
                        }
                    } 
                }
            }
        }
    }
    
    public func denyGroupPost(withGroupId groupId: String, withPostId postId: String, completion: @escaping(Bool) -> Void) {
        let postRef = database.child("groups").child(groupId).child("content").child("review").child("posts").queryOrdered(byChild: "id").queryEqual(toValue: postId)
        postRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count == 1 {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    self.database.child("groups").child(groupId).child("content").child("review").child("posts").child(key).removeValue { error, _ in
                        
                        if let error = error {
                            completion(false)
                            return
                        }
                        
                        /*
                        GroupService.deleteGroupPost(groupId: groupId, postId: postId) { error in
                            if let error = error {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                         */
                    }
                }
            }
        }
    }
    
    public func approveGroupCase(withGroupId groupId: String, withCaseId caseId: String, completion: @escaping(Bool) -> Void) {
        let caseRef = database.child("groups").child(groupId).child("content").child("review").child("cases").queryOrdered(byChild: "id").queryEqual(toValue: caseId)
        caseRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count == 1 {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    self.database.child("groups").child(groupId).child("content").child("review").child("cases").child(key).removeValue { error, _ in
                        
                        if let error = error {
                            completion(false)
                            return
                        }
                        let ref = self.database.child("groups").child(groupId).child("content").child("all").childByAutoId()
                        let groupRef = self.database.child("groups").child(groupId).child("content").child("cases").child(caseId).child("timestamp")
                        
                        let timestamp = NSDate().timeIntervalSince1970
                        
                        let data = ["id": caseId,
                                    "timestamp": timestamp,
                                    "type": 0] as [String: Any]
                        
                        ref.setValue(data) { error, _ in
                            if let _ = error {
                                completion(false)
                            }
                            
                            groupRef.setValue(timestamp) { error, _ in
                                if let _ = error {
                                    completion(false)
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func denyGroupCase(withGroupId groupId: String, withCaseId caseId: String, completion: @escaping(Bool) -> Void) {
        let caseRef = database.child("groups").child(groupId).child("content").child("review").child("cases").queryOrdered(byChild: "id").queryEqual(toValue: caseId)
        caseRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count == 1 {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    self.database.child("groups").child(groupId).child("content").child("review").child("cases").child(key).removeValue { error, _ in
                        
                        if let error = error {
                            completion(false)
                            return
                        }
                        /*
                        GroupService.deleteGroupCase(groupId: groupId, caseId: caseId) { error in
                            if let error = error {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                         */
                    }
                }
            }
        }
    }
    
    public func fetchPendingCasesForGroup(withGroupId groupId: String, completion: @escaping([ContentGroup]) -> Void) {
        var recentContent = [ContentGroup]()
        let postsRef = database.child("groups").child(groupId).child("content").child("review").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        postsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentContent.append(ContentGroup(dictionary: value))
                //recentComments.append(value)
            }
            completion(recentContent.reversed())
        }
    }
}

//MARK: - Companies

extension DatabaseManager {
    public func uploadCompany(companyId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("companies").child(companyId).child("managers").childByAutoId()
        let creationTimestampDate = NSDate().timeIntervalSince1970
        
        let managerUser = ["uid": uid,
                           "tiestamp": creationTimestampDate] as [String : Any]
        
        ref.setValue(managerUser) { error, _ in
            let userRef = self.database.child("users").child(uid).child("companies").childByAutoId()
            
            let newCompany = ["companyId": companyId,
                            "memberType": 0]
            
            userRef.setValue(newCompany) { error, _ in
                if let _ = error {
                    completion(false)
                    return
                }
                
                self.database.child("companies").child(companyId).child("allUsers").setValue(1) { error, _ in
                    if let _ = error {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
        }
    }
}

extension DatabaseManager {
    public func uploadJob(jobId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("jobs").child(jobId).child("managers").childByAutoId()
        let creationTimestampDate = NSDate().timeIntervalSince1970
        
        let managerUser = ["uid": uid,
                           "timestamp": creationTimestampDate] as [String : Any]
        
        ref.setValue(managerUser) { error, _ in
            let userRef = self.database.child("users").child(uid).child("jobs").childByAutoId()
            
            let newCompany = ["jobId": jobId,
                              "type": 0]
            
            userRef.setValue(newCompany) { error, _ in
                if let _ = error {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    public func fetchManagingJobIds(completion: @escaping([String]) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        var jobIds = [String]()
        let ref = database.child("users").child(uid).child("jobs").queryOrdered(byChild: "type").queryEqual(toValue: Job.UserJobType.manager.rawValue)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.isEmpty {
                completion(jobIds)
                return
            } else {
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    if let jobId = value["jobId"] as? String {
                        jobIds.append(jobId)
                    }
                }
                completion(jobIds)
            }
            
        }
    }
    
    public func sendJobApplication(jobId: String, documentURL: String, phoneNumber: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("jobs").child(jobId).child("applicants").childByAutoId()
        
        let applicantJobRequestTimes = NSDate().timeIntervalSince1970
        
        let applicantUser = ["uid": uid,
                             "documentUrl": documentURL,
                             "phoneNumber": phoneNumber,
                             "timestamp": applicantJobRequestTimes] as [String : Any]
        
        ref.setValue(applicantUser) { error, _ in
            let userRef = self.database.child("users").child(uid).child("jobs").childByAutoId()
            
            let newJob = ["jobId": jobId,
                          "documentUrl": documentURL,
                          "type": Job.UserJobType.applicant.rawValue,
                          "timestamp": applicantJobRequestTimes] as [String : Any]
            
            userRef.setValue(newJob) { error, _ in
                if let _ = error {
                    completion(false)
                    return
                }

                completion(true)
            }
        }
    }
    
    public func removeJobApplication(jobId: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("jobs").child(jobId).child("applicants").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count == 1 {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    self.database.child("jobs").child(jobId).child("applicants").child(key).removeValue { error, _ in
                        if let _ = error {
                            completion(false)
                            return
                        }
                    }
                    
                    let userRef = self.database.child("users").child(uid).child("jobs").queryOrdered(byChild: "type").queryEqual(toValue: Job.UserJobType.applicant.rawValue)
                    userRef.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.children.allObjects.count == 1 {
                            if let value = snapshot.value as? [String: Any] {
                                guard let key = value.first?.key else { return }
                                self.database.child("users").child(uid).child("jobs").child(key).removeValue { error, _ in
                                    if let _ = error {
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
        }
    }
    
    public func rejectJobApplication(withJobId jobId: String, forUid uid: String, completion: @escaping(Bool) -> Void) {
        let ref = database.child("jobs").child(jobId).child("applicants").queryOrdered(byChild: uid).queryEqual(toValue: uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.count == 1 {
                if let value = snapshot.value as? [String: Any] {
                    guard let key = value.first?.key else { return }
                    self.database.child("jobs").child(jobId).child("applicants").child(key).removeValue { error, _ in
                        if let _ = error {
                            completion(false)
                            return
                        }
                    }
                    
                    let userRef = self.database.child("users").child(uid).child("jobs").queryOrdered(byChild: "type").queryEqual(toValue: Job.UserJobType.applicant.rawValue)
                    userRef.observeSingleEvent(of: .value) { snapshot in
                        if snapshot.children.allObjects.count == 1 {
                            if let value = snapshot.value as? [String: Any] {
                                guard let key = value.first?.key else { return }
                                self.database.child("users").child(uid).child("jobs").child(key).removeValue { error, _ in
                                    if let _ = error {
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
        }
    }
    
    public func fetchJobApplicationsForUser(completion: @escaping([JobApplicant]) -> Void) {
        var applicants = [JobApplicant]()
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("jobs").queryOrdered(byChild: "type").queryEqual(toValue: Job.UserJobType.applicant.rawValue)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.isEmpty {
                completion(applicants)
                return
            } else {
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    applicants.append(JobApplicant(dictionary: value))
                }
                completion(applicants)
            }
        }
    }
    
    public func fetchJobApplicationsForJob(withJobId jobId: String, completion: @escaping([JobUserApplicant]) -> Void) {
        var applicants = [JobUserApplicant]()
        let ref = database.child("jobs").child(jobId).child("applicants")
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.children.allObjects.isEmpty {
                completion(applicants)
                return
            } else {
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    applicants.append(JobUserApplicant(dictionary: value))
                }
                completion(applicants)
            }
        }
    }
    
    public func checkIfUserDidApplyForJob(jobId: String, completion: @escaping(Bool) ->Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("jobs").child(jobId).child("applicants").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
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
    public func uploadAboutSection(with aboutText: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child("\(uid)/profile/about")
        ref.setValue(aboutText) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func fetchAboutSection(forUid uid: String, completion: @escaping(Result<String, Error>) -> Void) {
        let ref = database.child("users").child("\(uid)/profile/about")
        
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(RTDError.failedToFetch))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists() else {
                completion(.success(String()))
                return
            }
            
            if let section = snapshot.value as? String {
                completion(.success(section))
            } else {
                completion(.failure(RTDError.failedToFetch))
            }
        }
    }
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


    /// Creates a new conversation with target user uid and first message sent
   // public func createNewConversation(withUid otherUserUid: String, name: String, firstMessage: Message, completion: @escaping (Double?) -> Void) {
        
        /*
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
        
        let messageDate = firstMessage.sentDate.timeIntervalSince1970.toDouble()
        //let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let conversationId = "conversation_\(firstMessage.messageId)"
        
        let latestMessage: [String: Any] = [
            "date": messageDate,
            "message": message,
            "is_read": true,
            "sender_uid": currentUid
        ]
        
        let recipientLatestMessage: [String: Any] = [
            "date": messageDate,
            "message": message,
            "is_read": false,
            "sender_uid": currentUid
        ]
        
        let newConversationData: [String: Any] = [
            "id": conversationId,
            "creation_date": messageDate,
            "other_user_uid": otherUserUid,
            "name": name,
            "latest_message": latestMessage
        ]
        
        let recipientNewConversationData: [String: Any] = [
            "id": conversationId,
            "creation_date": messageDate,
            "other_user_uid": currentUid,
            "name": currentName,
            "latest_message": recipientLatestMessage
        ]
        
        //Update recipient conversation entry
        let otherUserRef = database.child("users/\(otherUserUid)").child("conversations").childByAutoId()
        
        otherUserRef.setValue(recipientNewConversationData) { error, _ in
            if let _ = error {
                completion(nil)
                return
            }
            
            let ref = self.database.child("users/\(currentUid)").child("conversations").childByAutoId()
            
            ref.setValue(newConversationData) { error, _ in
                if let _ = error {
                    completion(nil)
                    return
                }
                
                completion(messageDate)
                self.finishCreatingConversation(name: name,
                                                conversationID: conversationId,
                                                firstMessage: firstMessage,
                                                completion: completion)
            }
        }
         */
  //  }
    

    /// Fetches and returns all conversations for the user with uid
    public func getAllConversations(forUid uid: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        let ref = database.child("users/\(uid)/conversations")
        
/*
        var fetchedConversations = [[String: Any]]()
        
        let ref = database.child("users/\(uid)/conversations")

        ref.observe(.value) { snapshot in
            fetchedConversations.removeAll()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else {
                    print("we couldt get any snaphsot")
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }

                fetchedConversations.append(value)
            }
            
            let conversations: [Conversation] = fetchedConversations.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let creationDate = dictionary["creation_date"] as? TimeInterval,
                      let otherUserUid = dictionary["other_user_uid"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? TimeInterval,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"]  as? Bool,
                      let senderUid = latestMessage["sender_uid"] as? String else {
                    print("conversation with \(dictionary["name"]) is nil")
                    return nil  }
                
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead,
                                                        senderUid: senderUid)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserUid: otherUserUid,
                                    creationDate: creationDate,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        }
 */
    }
    
    
    /// Get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, withCreationDate creationDate: Double?, completion: @escaping(Result<[Message], Error>) -> Void) {
        /*
        var messages = [[String: Any]]()
        
        if let creationDate = creationDate {
            // User is opening conversation that already exists. Either it is active or it has been deleted in the past
            // Check the creationDate of the conversation and fetch messages greater than creationDate
            let messagesRef = database.child("conversations/\(id)/messages").queryOrdered(byChild: "date").queryStarting(atValue: creationDate)
                                                                                                                                                          
            messagesRef.observe(.value) { snapshot in
                messages.removeAll()
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    messages.append(value)
                }
                
                let conversationMessages: [Message] = messages.compactMap({ dictionary in
                    guard let name = dictionary["name"] as? String,
                          let isRead = dictionary["is_read"] as? Bool,
                          let messageID = dictionary["id"] as? String,
                          let content = dictionary["content"] as? String,
                          let senderUid = dictionary["sender_uid"] as? String,
                          let type = dictionary["type"] as? String,
                          let date = Date(timeIntervalSince1970: dictionary["date"] as! TimeInterval) as? Date
                          else { return nil }
                    
                    
                    var kind: MessageKind?
                    if type == "photo" {
                        guard let imageUrl = URL(string: content), let placeHolder = UIImage(systemName: "plus") else { return nil }
                        let media = Media(url: imageUrl,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: CGSize(width: 150, height: 150))
                        kind = .photo(media)
                    } else if type == "video" {
                        //Placeholder should be a thumbnail of the video
                        guard let imageUrl = URL(string: content), let placeHolder = UIImage(systemName: "play.circle.fill")?.withTintColor(.clear, renderingMode: .alwaysOriginal) else { return nil }
                        
                        let media = Media(url: imageUrl,
                                          image: nil,
                                          placeholderImage: placeHolder,
                                          size: CGSize(width: 150, height: 150))
                        kind = .video(media)
                        
                        
                    }
                    else {
                        kind = .text(content)
                    }
                    
                    guard let finalKind = kind else { return nil }
                    
                    let sender = Sender(userProfileImageUrl: "",
                                        senderId: senderUid,
                                        displayName: name)
                    
                    return Message(sender: sender,
                                   messageId: messageID,
                                   sentDate: date,
                                   kind: finalKind)
                })
                
                completion(.success(conversationMessages))
            }
        }
        // There's not creationDate for the conversation so don't fetch any messages
        completion(.failure(DatabaseError.failedToFetch))
         */
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, otherUserUid: String, newMessage: Message, completion: @escaping (Double?) -> Void) {
        /*
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(nil)
            return
        }
        
        let messageDate = newMessage.sentDate.timeIntervalSince1970.toDouble()
        
        var message = ""
        
        switch newMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let targetUrl = mediaItem.url?.absoluteString {
                message = targetUrl
            }
            break
        case .video(let mediaItem):
            if let targetUrl = mediaItem.url?.absoluteString {
                message = targetUrl
            }
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        // Create the new message entry for the current conversation between both users
        let newMessageEntry: [String: Any] = [
            "id": newMessage.messageId,
            "type": newMessage.kind.messageKindString,
            "content": message,
            "date": messageDate,
            "sender_uid": currentUid,
            "is_read": false,
            "name": name
        ]
        
        // Update the recent message for the current user
        let newLastMessageSent: [String: Any] = [
            "date": messageDate,
            "is_read": true,
            "message": message,
            "sender_uid": currentUid
        ]
        
        // Update the recent message for the other user
        let newLastMessageReceived: [String: Any] = [
            "date": messageDate,
            "is_read": false,
            "message": message,
            "sender_uid": currentUid
        ]
        
        // Set a new message to the conversation between users
        let conversationRef = database.child("conversations/\(conversation)/messages").childByAutoId()
        conversationRef.setValue(newMessageEntry) { error, _ in
            if let _ = error {
                completion(nil)
                return
            }
        }
        
        let otherUserRef = self.database.child("users/\(otherUserUid)/conversations").queryOrdered(byChild: "id").queryEqual(toValue: conversation)
        otherUserRef.observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                // We go to the exact node of the user target conversation to update it
                let ref = self.database.child("users").child(otherUserUid).child("conversations").child(key).child("latest_message")
                ref.setValue(newLastMessageReceived) { error, _ in
                    if let _ = error {
                        completion(nil)
                        return
                    }
                }
            } else {
                // Other user reference is not found, means the conversation has been deleted, create a new conversation
                let otherUserNewConversationData: [String: Any] = [
                    "id": conversation,
                    "creation_date": messageDate,
                    "other_user_uid": otherUserUid,
                    "name": name,
                    "latest_message": newLastMessageReceived
                ]
                
                // Add the conversation to the other user, updating it's creation date
                let newOtherUserConversationRef = self.database.child("users/\(otherUserUid)/conversations").childByAutoId()
                newOtherUserConversationRef.setValue(otherUserNewConversationData) { error, _ in
                    if let _ = error {
                        completion(nil)
                        return
                    }
                }
            }
        })

        // Update the conversation of current user after sending the message
        // Update the current conversation as the conversation exists
        // Search the conversation id in the user conversations database
        let currentRef = self.database.child("users/\(currentUid)/conversations").queryOrdered(byChild: "id").queryEqual(toValue: conversation)
        print("Start to update current user")
        currentRef.observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                print("We found snapshot")
                guard let key = value.first?.key else { return }
                print("We found key \(key)")
                // We go to the exact node of the user target conversation to update it
                let newRef = self.database.child("users").child(currentUid).child("conversations").child(key).child("latest_message")
                newRef.setValue(newLastMessageSent) { error, _ in
                    if let error = error {
                        print("we got an error \(error.localizedDescription) ")
                        completion(nil)
                        return
                    }
                    print("We could update the latest message value of the sender user")
                }
            } else {
                // Current user didn't found the conversation saved, means it was deleted at some point.
                // Create a new Conversation
                 let newConversationData: [String: Any] = [
                     "id": conversation,
                     "creation_date": messageDate,
                     "other_user_uid": otherUserUid,
                     "name": name,
                     "latest_message": newLastMessageSent
                 ]
                
                let newCurrentUserConversationRef = self.database.child("users/\(currentUid)/conversations").childByAutoId()
                newCurrentUserConversationRef.setValue(newConversationData) { error, _ in
                    if let _ = error {
                        completion(nil)
                        return
                    }
                    completion(messageDate)
                }
            }
        })
         */
    }

    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Double?) -> Void) {
        /*
        let messageDate = firstMessage.sentDate.timeIntervalSince1970.toDouble()
        //let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(nil)
            return
        }
        
        
        let messageData: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": messageDate,
            "sender_uid": currentUserUid,
            "is_read": false,
            "name": name
        ]
        
      
        print("adding convo: \(conversationID)")
        
        database.child("conversations/\(conversationID)/messages").childByAutoId().setValue(messageData, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(nil)
                return
            }
            completion(messageDate)
        })
    }
    
    ///Deletes a conversation with conversationID for the target user
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //Get all conversations for current user
        let ref = database.child("users/\(uid)/conversations").queryOrdered(byChild: "id").queryEqual(toValue: conversationId)
        ref.observeSingleEvent(of: .value) { snapshot, _  in
            if let value = snapshot.value as? [String: Any] {
                if let key = value.keys.first {
                    self.database.child("users/\(uid)/conversations").child(key).removeValue { error, _ in
                        if let _ = error {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    /// Check if the conversation already exists in conversation list
    public func conversationExists(with targetRecipientUid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        print("We check if the conversation exists")
        // Current user does not have the conversation, so we first check if the other user has the conversation
        // If the other user has the conversation means we did deleted it at some point
        // If the other user does not have a conversation means we never had an active conversation or both users deleted it, either way create a new one
        let ref = database.child("users/\(targetRecipientUid)/conversations").queryOrdered(byChild: "other_user_uid").queryEqual(toValue: uid)
        
        ref.observeSingleEvent(of: .value) { snapshot, error  in
            if let _ = error {
                // We still don't have a conversation with this user or both deleted it
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        
            if let value = snapshot.value as? [String: Any] {
                print("We have a conversation with the other user and we deleted it at some point")
                // We have a conversation with the other user and we deleted it at some point
                if let key = value.keys.first {
                    // We try to get the conversationID both users had in the past
                    let newRef = self.database.child("users").child(targetRecipientUid).child("conversations").child(key).child("id")
                    newRef.getData { error, snapshot in
                        if let value = snapshot?.value as? String {
                            // We get the conversationID to continue on the same conversation it was at some point
                            print(value)
                            completion(.success(value))
                        }
                    }
                }
            } else {
                print("We still don't have a conversation with this user or both deleted it")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
        }
         */
    }
    
    public func makeLastMessageStateToIsRead(conversationID: String, isReadState isRead: Bool) {
        /*
         guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
         
         let ref = database.child("users").child(uid).child("conversations").queryOrdered(byChild: "id").queryEqual(toValue: conversationID)
         
         ref.observeSingleEvent(of: .value) { snapshot in
         if let value = snapshot.value as? [String: Any] {
         if let key = value.keys.first {
         let newRef = self.database.child("users").child(uid).child("conversations").child(key).child("latest_message").child("is_read")
         newRef.setValue(isRead) { error, _ in
         if let _ = error {
         return
         }
         }
         }
         }
         }
         }
         */
    }
}

//Move to models folder
struct ChatUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uid: String
    let profilePictureUrl: String
    let profession: String
    let speciality: String
    let category: String
}
