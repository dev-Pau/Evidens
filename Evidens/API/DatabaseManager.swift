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
                                           "emailAddress": user.emailAddress])
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
    
    public func filter() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        //let ref = database.child("users").child(uid).child("languages").queryOrdered(byChild: "languageName").queryEqual(toValue: "Spanish")
        let ref = database.child("users").child(uid).child("publications").queryOrdered(byChild: "title").queryEqual(toValue: "Publication 1")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let values = snapshot.value as? [String: Any] {
                print(values)
                print(values.keys)
  
            } else{
            print("no snapshot in corret format")
                }
        }
    }
    
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
    
    public func uploadPatent(title: String, number: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let patentData = ["title": title,
                          "number": number]
        
        let ref = database.child("users").child(uid).child("patents").childByAutoId()
        
        ref.setValue(patentData) { error, _ in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    public func fetchPatents(forUid uid: String, completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("patents")
        var recentPatents = [[String: String]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: String] else { return }
                recentPatents.append(value)
            }
            completion(.success(recentPatents))
        }
    }
    
    public func updatePatent(previousPatent: String, patentTitle: String, patentNumber: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let patentData = ["title": patentTitle,
                          "number": patentNumber]
            
        
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
    
    public func uploadPublication(title: String, url: String, date: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let publicationData = ["title": title,
                               "url": url,
                               "date": date]
        
        let ref = database.child("users").child(uid).child("publications").childByAutoId()
        
        
        
        ref.setValue(publicationData) { error, _ in
            if let _ = error {
                completion(false)
                return
                
            }
        }
        completion(true)
    }
    
    
    public func fetchPublications(forUid uid: String, completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        let ref = database.child("users").child(uid).child("publications")
        var recentPublications = [[String: String]]()
        
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = child.value as? [String: String] else { return }
                recentPublications.append(value)
            }
            completion(.success(recentPublications))
        }
    }
    
    public func updatePublication(previousPublication: String, publicationTitle: String, publicationUrl: String, publicationDate: String, completion: @escaping(Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let publicationData = ["title": publicationTitle,
                               "url": publicationUrl,
                               "date": publicationDate]
        
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
    
    
        
        //ref.observeSingleEvent(of: <#T##DataEventType#>, with: <#T##(DataSnapshot) -> Void#>)
        
        /*
         // Check if user has recent searches
         ref.observeSingleEvent(of: .value) { snapshot in
             if var recentSearches = snapshot.value as? [String] {
                 // Recent searches document exists, append new search
                 
                 // Check if the searched topic is already saved from the past
                 if recentSearches.contains(searchedTopic) {
                     completion(false)
                     return
                 }
                 recentSearches.append(searchedTopic)
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
         */


//MARK: - Sending messages & Conversations
extension DatabaseManager {
    
    /// Creates a new conversation with target user uid and first message sent
    public func createNewConversation(withUid otherUserUid: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }

        
        let ref = database.child("users/\(currentUid)")
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            
            print("User node is \(userNode)")
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
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
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "creation_date": dateString,
                "other_user_uid": otherUserUid,
                "name": name,
                "latest_message": ["date": dateString,
                                   "message": message,
                                   "is_read": false,
                                   "sender_uid": currentUid
                ]
            ]
            
            let recipientNewConversationData: [String: Any] = [
                "id": conversationId,
                "creation_date": dateString,
                "other_user_uid": currentUid,
                "name": currentName,
                "latest_message": ["date": dateString,
                                   "message": message,
                                   "is_read": false,
                                   "sender_uid": currentUid
                ]
            ]
            
            //Update recipient conversation entry
            self?.database.child("users/\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //Append
                    print("Other user has conversations")
                    conversations.append(recipientNewConversationData)
                    self?.database.child("users/\(otherUserUid)/conversations").setValue(conversations)
                } else {
                    //Create new conversation
                    print("Other user does not have conversations, create the conversation array with the latest message etc")
                    self?.database.child("users/\(otherUserUid)/conversations").setValue([recipientNewConversationData])
                }
            })
            
            //Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //Conversation array exists for current user, append
                print("Conversation array exists for current user, means he has other conversations with other users")
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            } else {
                
                //Conversation array does not exist, create it
                print("user doesn't have any conversation, create the array")
                userNode["conversations"] = [newConversationData]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    print("we go create the conversation child in realtime")
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        }
    }
    

    /// Fetches and returns all conversations for the user with uid
    public func getAllConversations(forUid uid: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("users/\(uid)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let creationDate = dictionary["creation_date"] as? String,
                      let otherUserUid = dictionary["other_user_uid"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"]  as? Bool,
                      let senderUid = latestMessage["sender_uid"] as? String else { return nil }
                
                
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
        })
    }
    
    /// Get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        database.child("conversations/\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderUid = dictionary["sender_uid"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else { return nil }

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
            completion(.success(messages))
        })
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, otherUserUid: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        //Add new message to messages
        //Update sender latest message
        //Update recipient latest message
        
        guard let currentUid = UserDefaults.standard.value(forKey: "uid") as? String else {
            completion(false)
            return
        }
        
        self.database.child("conversations/\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            print("We get all the messages of the conversation with this user: \(currentMessages)")
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
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
                //if let audioItem = AudioItem. {
                    
                //}
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_uid": currentUid,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            print("We append this new message")
            
            strongSelf.database.child("conversations/\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                print("We append the new message in the conversation to realtime database")
                
            print("current user uid is \(currentUid)")
                strongSelf.database.child("users/\(currentUid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message,
                        "sender_uid": currentUid
                    ]
                    
                    print("value of snapshot is \(snapshot.value)")
            
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0
                        
                        print("We found the conversation array and we get the values of conversations \(currentUserConversations)")
                        
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                
                                //Update latest message
                                targetConversation = conversationDictionary
                                
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            print("We found the conversation")
                            print("We found the conversation andn we update it \(targetConversation)")
                            
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                            
                            print("New conversations to update into user updated is \(databaseEntryConversations)")
                            
                        } else {
                            //User must have deleted the conversation and we append as a fresh new entry
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_uid": otherUserUid,
                                "creation_date": dateString,
                                "name": name,
                                "latest_message": updatedValue
                                ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                        //There has never been a conversation, create new entry
                    } else {
                        print("We didnt find the conversation array for the current user, so we need to create a new entry")
                        
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_uid": otherUserUid,
                            "creation_date": dateString,
                            "name": name,
                            "latest_message": updatedValue
                            ]
                        databaseEntryConversations = [newConversationData]
                    }
                    
                    strongSelf.database.child("users/\(currentUid)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                })
                
                //Update latest message for recipient user
                strongSelf.database.child("users/\(otherUserUid)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message,
                        "sender_uid": currentUid
                    ]
                    
                    var databaseEntryConversations = [[String: Any]]()
                    guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
                    
                    print("for other user is \(snapshot.value)")
                    
                    if var otherUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        
                        var position = 0
                        
                        print("We find the conversation array for other user")
                        
                        for conversationDictionary in otherUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                //Update latest message
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            otherUserConversations[position] = targetConversation
                            databaseEntryConversations = otherUserConversations
                        } else {
                            //Failed to find in current collection
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_uid": currentUid,
                                "creation_date": dateString,
                                "name": currentName,
                                "latest_message": updatedValue
                                ]
                            otherUserConversations.append(newConversationData)
                            databaseEntryConversations = otherUserConversations
                        }
                    } else {
                        //Current collection does not exist
                        print("We didnt find users array for other user create it ")
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_uid": currentUid,
                            "creation_date": dateString,
                            "name": currentName,
                            "latest_message": updatedValue
                            ]
                        databaseEntryConversations = [newConversationData]
                    }
                    
                    strongSelf.database.child("users/\(otherUserUid)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                })
                completion(true)
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
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
            completion(false)
            return
        }
        
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_uid": currentUserUid,
            "is_read": false,
            "name": name
        ]
        
        let value : [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding convo: \(conversationID)")
        
        database.child("conversations/\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Deletes a conversation with conversationID for the target user
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //Get all conversations for current user
        let ref = database.child("users/\(uid)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId {
                        break
                    }
                    positionToRemove += 1
                }
                //Delete conversation in collection with target conversationID
                conversations.remove(at: positionToRemove)
                //Reset those conversations for the user in the database
                ref.setValue(conversations) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    /// Check if the conversation already exists in conversation list
    public func conversationExists(with targetRecipientUid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let senderUid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        //Get the original conversationID between both users
        database.child("users/\(targetRecipientUid)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            //Iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderUid = $0["other_user_uid"] as? String else { return false }
                return senderUid == targetSenderUid
            }) {
                //Get the id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
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
