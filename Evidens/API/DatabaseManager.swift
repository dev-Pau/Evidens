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
    public func insertUser(with user: ChatUser) {
        //Create user entry based on UID
        database.child("users").child(user.uid).setValue(["firstName": user.firstName.capitalized,
                                                          "lastName": user.lastName.capitalized,
                                                          "emailAddress": user.emailAddress,
                                                          "helpers": ["home": true]])
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
    
    public enum DatabaseError: Error {
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
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let recentSearches = snapshot?.value as? [String] {
                completion(.success(recentSearches.reversed()))
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

                if recentSearches.count == 5 {
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
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let recentSearches = snapshot?.value as? [String] {
                completion(.success(recentSearches.reversed()))
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
                completion(.failure(DatabaseError.failedToFetch))
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
        let ref = database.child("users").child("\(uid)/comments").childByAutoId()
        
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
    
    public func fetchRecentComments(forUid uid: String, completion: @escaping(Result<[[String: Any]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("comments").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        var recentComments = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentComments.append(value)
            }
            completion(.success(recentComments.reversed()))
        }
    }
    
    public func fetchProfileComments(for uid: String, completion: @escaping(Result<[[String: Any]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("comments").queryOrdered(byChild: "timestamp")
        var recentComments = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentComments.append(value)
            }
            completion(.success(recentComments.reversed()))
        }
    }
    
    public func fetchProfileComments(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[[String: Any]], Error>) -> Void) {
        var recentComments = [[String: Any]]()
        if lastTimestampValue == nil {
            // First group to fetch
            let ref = database.child("users").child(uid).child("comments").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            ref.observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    recentComments.append(value)
                }
                completion(.success(recentComments.reversed()))
            }
        } else {
            // Fetch more posts
            let ref = database.child("users").child(uid).child("comments").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)

            ref.observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    recentComments.append(value)
                }
                completion(.success(recentComments.reversed()))
            }
        }
    }
    
    public func deleteRecentComment(forCommentId commentID: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("comments")
        let query = ref.queryOrdered(byChild: "commentUid").queryEqual(toValue: commentID).queryLimited(toFirst: 1)
        
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
        let ref = database.child("users").child("\(uid)/posts/\(postUid)/timestamp")
        
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
        
    
        let ref = database.child("users").child(uid).child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let values = snapshot.value as? [String: Any] {
                print(values)
                values.forEach { value in
                    uids.append(value.key)
                }
                completion(.success(uids))
            }
        }
    }
    
    public func fetchHomeFeedPosts(lastTimestampValue: Int64?, forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        
        var uids: [String] = []
        
        if lastTimestampValue == nil {
            // First group to fetch
            let ref = database.child("users").child(uid).child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    print(values)
                    values.forEach { value in
                        uids.append(value.key)
                    }
                    completion(.success(uids))
                }
            }
            
        } else {
            // Fetch more posts
            let ref = database.child("users").child(uid).child("posts").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            
            
            //queryStarting(afterValue: lastTimestampValue).queryLimited(toFirst: 1)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    print(values)
                    values.forEach { value in
                        uids.append(value.key)
                    }
                    completion(.success(uids))
                }
            }
        }
    } 
}

//MARK: - Report Posts & Cases

extension DatabaseManager {
    
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
    
    public func uploadLanguage(language: String, proficiency: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        //let ref = database.child("users").child("\(uid)/languages")
        
        let languageData = ["languageName": language,
                             "languageProficiency": proficiency]
        
        let ref = database.child("users").child(uid).child("languages").childByAutoId()
        
        
        
        ref.setValue(languageData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func fetchLanguages(forUid uid: String, completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        var recentLanguages = [[String: String]]()
        
        let ref = database.child("users").child(uid).child("languages")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: String] else { return }
                recentLanguages.append(value)
            }
            completion(.success(recentLanguages))
        }
    }
    

    public func updateLanguage(previousLanguage: String, languageName: String, languageProficiency: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let updatedLanguage = ["languageName": languageName,
                               "languageProficiency": languageProficiency]
        
        
        let ref = database.child("users").child(uid).child("languages").queryOrdered(byChild: "languageName").queryEqual(toValue: previousLanguage)
        
        ref.getData { _, snapshot in
            if let value = snapshot?.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let newRef = self.database.child("users").child(uid).child("languages").child(key)
                newRef.setValue(updatedLanguage) { error, _ in
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

//MARK: - User Patents

extension DatabaseManager {
    
    public func uploadPatent(title: String, number: String, contributors: [String], completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let patentData = ["title": title,
                          "number": number,
                          "contributors": contributors] as [String : Any]
                         
        
        let ref = database.child("users").child(uid).child("patents").childByAutoId()
        
        ref.setValue(patentData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    public func fetchPatents(forUid uid: String, completion: @escaping(Result<[[String: Any]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("patents")
        var recentPatents = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentPatents.append(value)
            }
            completion(.success(recentPatents))
        }
    }
    
    public func updatePatent(previousPatent: String, patentTitle: String, patentNumber: String, contributors: [String], completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let patentData = ["title": patentTitle,
                          "number": patentNumber,
                          "contributors": contributors] as [String: Any]
            
        
        let ref = database.child("users").child(uid).child("patents").queryOrdered(byChild: "title").queryEqual(toValue: previousPatent)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                guard let key = value.first?.key else { return }
                
                let newRef = self.database.child("users").child(uid).child("patents").child(key)
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
}

//MARK: - User Publications

extension DatabaseManager {
    
    public func uploadPublication(title: String, url: String, date: String, contributors: [String], completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let publicationData = ["title": title,
                               "url": url,
                               "date": date,
                               "contributors": contributors] as [String: Any]
        
        let ref = database.child("users").child(uid).child("publications").childByAutoId()
        
        
        
        ref.setValue(publicationData) { error, _ in
            if let _ = error {
                completion(false)
                return
                
            }
        }
        completion(true)
    }
    
    
    public func fetchPublications(forUid uid: String, completion: @escaping(Result<[[String: Any]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("publications")
        var recentPublications = [[String: Any]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                recentPublications.append(value)
            }
            completion(.success(recentPublications))
        }
    }
    
    public func updatePublication(previousPublication: String, publicationTitle: String, publicationUrl: String, publicationDate: String, contributors: [String], completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let publicationData = ["title": publicationTitle,
                               "url": publicationUrl,
                               "date": publicationDate,
                               "contributors": contributors] as [String: Any]
        
        //let ref = database.child("users").child(uid).child("languages").queryOrdered(byChild: "languageName").queryEqual(toValue: previousLanguage)
        let ref = database.child("users").child(uid).child("publications").queryOrdered(byChild: "title").queryEqual(toValue: previousPublication)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            print(snapshot)
            if let value = snapshot.value as? [String: Any] {
                
                guard let key = value.first?.key else { return }

                let newRef = self.database.child("users").child(uid).child("publications").child(key)
                newRef.setValue(publicationData) { error, _ in
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

//MARK: - User Education

extension DatabaseManager {
    
    public func uploadEducation(school: String, degree: String, field: String, startDate: String, endDate: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let educationData = ["school": school,
                               "degree": degree,
                               "field": field,
                               "startDate": startDate,
                               "endDate": endDate]
      
        let ref = database.child("users").child(uid).child("education").childByAutoId()
        
        ref.setValue(educationData) { error, _ in
            if let _ = error {
                completion(false)
                return
                
            }
        }
        completion(true)
    }
    
    public func fetchEducation(forUid uid: String, completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("education")
        var recentPublications = [[String: String]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: String] else { return }
                recentPublications.append(value)
            }
            completion(.success(recentPublications.reversed()))
        }
    }
    
    /// Uploads education based on degree selected. In case the user has more than one degree, compares with school & field to find the exact child to update
    ///     /// Parameters:
    /// - `previousDegree`:     Degree to update by de user
    /// - `previousSchool`:     School to update by de user
    /// - `previousField`:       Field to update by de user
    /// - `school, degree & type, field, startDate, endDate`:   New values of education details
    public func updateEducation(previousDegree: String, previousSchool: String, previousField: String, school: String, degree: String, field: String, startDate: String, endDate: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let educationData = ["school": school,
                             "degree": degree,
                             "field": field,
                             "startDate": startDate,
                             "endDate": endDate]
        
        // Query to fetch based on previousDegree
        let ref = database.child("users").child(uid).child("education").queryOrdered(byChild: "degree").queryEqual(toValue: previousDegree)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            // Check if the user has more than one child with the same degree type
            if snapshot.children.allObjects.count > 1 {
                // The user has more than one degree type compare every snapshot with previous school & field
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    guard let previousUserField = value["field"] as? String, let previousUserSchool = value["school"] as? String else { return }
                    if previousUserField == previousField && previousUserSchool == previousSchool {
                        // Found the exact child to update with the child.key
                        let newRef = self.database.child("users").child(uid).child("education").child(child.key)
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
                    let newRef = self.database.child("users").child(uid).child("education").child(key)
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
}


//MARK: - User Experience

extension DatabaseManager {
    
    public func uploadExperience(role: String, company: String, startDate: String, endDate: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
         
        let experienceData = ["role": role,
                              "company": company,
                              "startDate": startDate,
                              "endDate": endDate]
    
        let ref = database.child("users").child(uid).child("experience").childByAutoId()
        
        ref.setValue(experienceData) { error, _ in
            if let _ = error {
                completion(false)
                return
                
            }
        }
        completion(true)
    }
    
    public func fetchExperience(forUid uid: String, completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("experience")
        var recentExperience = [[String: String]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: String] else { return }
                recentExperience.append(value)
            }
            completion(.success(recentExperience.reversed()))
        }
    }
    
    public func updateExperience(previousCompany: String, previousRole: String, company: String, role: String, startDate: String, endDate: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let experienceData = ["role": role,
                              "company": company,
                              "startDate": startDate,
                              "endDate": endDate]
        
        // Query to fetch based on previousDegree
        let ref = database.child("users").child(uid).child("experience").queryOrdered(byChild: "role").queryEqual(toValue: previousRole)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            // Check if the user has more than one child with the same degree type
            if snapshot.children.allObjects.count > 1 {
                // The user has more than one degree type compare every snapshot with previous school & field
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    guard let previousUserCompany = value["company"] as? String else { return }
                    if previousUserCompany == previousCompany {
                        // Found the exact child to update with the child.key
                        let newRef = self.database.child("users").child(uid).child("experience").child(child.key)
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
                    let newRef = self.database.child("users").child(uid).child("experience").child(key)
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
        uids.forEach { uid in

            let existsRef = database.child("groups").child(groupId).child("users").queryOrdered(byChild: "uid").queryEqual(toValue: uid)
            existsRef.observeSingleEvent(of: .value) { snapshot in
                guard !snapshot.exists() else {
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
                        completion(true)
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
                completion(.failure(DatabaseError.failedToFetch))
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
                completion(.failure(DatabaseError.failedToFetch))
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
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any], let uid = value["uid"] as? String else { return }
                uids.append(uid)
            }
            completion(uids)
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
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: Any] else { return }
                adminUsers.append(UserGroup(dictionary: value))
            }  
            completion(adminUsers)
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
            
            if !snapshot.exists() {
                completion(Group.MemberType.external)
            }
            
            snapshot.children.forEach { child in
                if let child = child as? DataSnapshot, let value = child.value as? [String: Any], let memberType = value["memberType"] as? Int {
                    completion(Group.MemberType(rawValue: memberType)!)
                }
            }
        }
    }
    
    public func uploadRecentPostToGroup(withGroupId groupId: String, withPostId postId: String, withPermission permission: Group.Permissions, completion: @escaping (Bool) -> Void) {
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
    
    public func uploadRecentCaseToGroup(withGroupId groupId: String, withCaseId caseId: String, withPermission permission: Group.Permissions, completion: @escaping(Bool) -> Void) {
        
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
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    recentContent.append(ContentGroup(dictionary: value))
                }
                completion(recentContent.reversed())
            }
        } else {
            let contentRef = database.child("groups").child(groupId).child("content").child("all").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            contentRef.observeSingleEvent(of: .value) { snapshot in
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let value = child.value as? [String: Any] else { return }
                    recentContent.append(ContentGroup(dictionary: value))
                }
                completion(recentContent.reversed())
            }
        }
    }
    
    public func fetchAllGroupPosts(withGroupId groupId: String, lastTimestampValue: Int64?, completion: @escaping([String]) -> Void) {
        var postIds = [String]()
        if lastTimestampValue == nil {
            // Fetch first group posts
            let postsRef = database.child("groups").child(groupId).child("content").child("posts").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            postsRef.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        postIds.append(value.key)
                    }
                    completion(postIds)
                }
            }
        } else {
            // Fetch more posts
            let postsRef = database.child("groups").child(groupId).child("content").child("posts").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            postsRef.observeSingleEvent(of: .value) { snapshot in
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        postIds.append(value.key)
                    }
                    completion(postIds)
                }
            }
        }
    }
    
    public func fetchAllGroupCases(withGroupId groupId: String, lastTimestampValue: Int64?, completion: @escaping([String]) -> Void) {
        var caseIds = [String]()
        if lastTimestampValue == nil {
            let casesRef = database.child("groups").child(groupId).child("content").child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
            casesRef.observeSingleEvent(of: .value) { snapshot in
                
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        caseIds.append(value.key)
                    }
                    completion(caseIds)
                }
            }
        } else {
            let casesRef = database.child("groups").child(groupId).child("content").child("cases").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestampValue).queryLimited(toLast: 10)
            casesRef.observeSingleEvent(of: .value) { snapshot in
                
                if let values = snapshot.value as? [String: Any] {
                    values.forEach { value in
                        caseIds.append(value.key)
                    }
                    completion(caseIds)
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
                        
                        GroupService.deleteGroupPost(groupId: groupId, postId: postId) { error in
                            if let error = error {
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
                        
                        GroupService.deleteGroupCase(groupId: groupId, caseId: caseId) { error in
                            if let error = error {
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



//MARK: - User Recent Cases

extension DatabaseManager {
    
    public func uploadRecentCase(withUid caseUid: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let ref = database.child("users").child(uid).child("cases").child(caseUid).child("timestamp")
        
        let timestamp = NSDate().timeIntervalSince1970
        
        ref.setValue(timestamp) { error, _ in
            if let _ = error {
                completion(false)
            }
            completion(true)
        }
    }
    
    public func fetchRecentCases(forUid uid: String, completion: @escaping(Result<[String], Error>) -> Void) {
        var uids: [String] = []
        
        let ref = database.child("users").child(uid).child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 3)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let values = snapshot.value as? [String: Any] {
                values.forEach { value in
                    uids.append(value.key)
                }
                completion(.success(uids))
            }
        }
    }
    
    public func checkIfUserHasMoreThanThreeVisibleCases(forUid uid: String, completion: @escaping(Int) -> Void) {
        let ref = database.child("users").child(uid).child("cases").queryOrdered(byChild: "timestamp").queryLimited(toLast: 4)
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
        let ref = database.child("users").child("\(uid)/about")
        ref.setValue(aboutText) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func fetchAboutSection(forUid uid: String, completion: @escaping(Result<String, Error>) -> Void) {
        let ref = database.child("users").child("\(uid)/about")
        ref.getData { error, snapshot in
            guard error == nil else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let section = snapshot?.value as? String {
                completion(.success(section))
            } else {
                completion(.failure(DatabaseError.failedToFetch))
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
    
    /// Creates a new conversation with target user uid and first message sent
    public func createNewConversation(withUid otherUserUid: String, name: String, firstMessage: Message, completion: @escaping (Double?) -> Void) {
        
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
    }
    

    /// Fetches and returns all conversations for the user with uid
    public func getAllConversations(forUid uid: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {

        var fetchedConversations = [[String: Any]]()
        
        let ref = database.child("users/\(uid)/conversations")
        print("We get all conversations")
        
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
    }
    
    
    /// Get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, withCreationDate creationDate: Double?, completion: @escaping(Result<[Message], Error>) -> Void) {
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
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, otherUserUid: String, newMessage: Message, completion: @escaping (Double?) -> Void) {
        
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
    }

    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Double?) -> Void) {
        
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
    }
    
    public func makeLastMessageStateToIsRead(conversationID: String, isReadState isRead: Bool) {
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
