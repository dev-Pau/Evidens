//
//  UserService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import Firebase
import FirebaseAuth
import Foundation

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    
    static func updateProfileUrl(profileImageUrl: String, completion: @escaping(Bool) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["profileImageUrl" : profileImageUrl], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            } else {
                print("Document succesfully written!")
                completion(true)
            }
        }
    }
    
    static func updateBannerUrl(bannerImageUrl: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["bannerImageUrl" : bannerImageUrl], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
                return
            } else {
                print("Document succesfully written!")
                completion(true)
            }
        }
    }
    
    static func updateUserFirstName(firstName: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["firstName": firstName.capitalized], merge: true) { err in
            
            if let err = err {
                print("Error writing document: \(err)")
                completion(err)
                return
            } else {
                print("Document succesfully written!")
                completion(nil)
            }
        }
    }
    
    static func updateUserLastName(lastName: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["lastName": lastName.capitalized], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(err)
            } else {
                print("Document succesfully written!")
                completion(nil)
            }
        }
    }
    
    static func updateProfileImageUrl(profileImageUrl: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).updateData(["profileImageUrl": profileImageUrl], completion: completion)
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            
            guard let dictionary = snapshot?.data() else { return }
            
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchRelatedUsers(withProfession profession: String, completion: @escaping([User]) -> Void) {
        var usersFetched: [User] = []
        COLLECTION_USERS.whereField("profession", isEqualTo: profession).limit(to: 10).getDocuments { snapshot, error in
            if let error = error {
                print("error getting documents: \(error)")
            } else {
                snapshot?.documents.forEach({ document in
                    let dictionary = document.data()
                    
                    usersFetched.append(User(dictionary: dictionary))
                    if usersFetched.count == snapshot?.documents.count {
                        completion(usersFetched)
                        
                    }
                })
            }
        }
    }
    
    static func fetchUsers(withUids uids: [String], completion: @escaping([User]) -> Void) {
        var users: [User] = []
        uids.forEach { uid in
            COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                users.append(User(dictionary: dictionary))
                if users.count == uids.count {
                    completion(users)
                }
            }
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            let users = snapshot.documents.map({ User(dictionary: $0.data()) })
            completion(users)
        }
    }
    
    static func fetchFollowers(forUid uid: String, completion: @escaping([String?]) -> Void) {
       var userUids = [String]()
        
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let uids = snapshot?.documents  else {
                return }
            uids.forEach { document in
                userUids.append(document.documentID)
            }
            completion(userUids)
        }
    }
    
    static func fetchFollowing(forUid uid: String, completion: @escaping([String]) -> Void) {
        var userUids = [String]()
         
         COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
             guard let uids = snapshot?.documents  else {
                 return }
             uids.forEach { document in
                 userUids.append(document.documentID)
             }
             completion(userUids)
         }
     }
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete() { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { (snapshot, error) in
            //If snapshot exists means user is followed by current user
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    #warning("Only for testing purposes, for counting number of likes and display without updating the document field likes")
   
    static func fetchUserFollowerws() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let query = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        query.getAggregation(source: .server) { snaphsot, _ in
            print(snaphsot?.count)
        }
        
        /*let query = COLLECTION_FOLLOWERS.document(uid).collection("user-followers").count
        do {
            let snapshot = try await query.getAggregation(source: .server)
            print(snapshot.count)
        } catch {
            print(error)
        }
         */
        
        
    }
    
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
            let followers = snapshot?.documents.count ?? 0
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
                let following = snapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { (snapshot, _) in
                    let posts = snapshot?.documents.count ?? 0
                    
                    
                    COLLECTION_CASES.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
                        
                        guard let documents = snapshot?.documents else {
                            completion(UserStats(followers: followers, following: following, posts: posts, cases: 0))
                            return
                        }
                    
                        var cases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                        
                        cases.enumerated().forEach { index, clinicalCase in
                            if clinicalCase.privacyOptions == .nonVisible {
                                cases.remove(at: index)
                            }
                        }
                        
                        let numOfCases = cases.count
                        
                        completion(UserStats(followers: followers, following: following, posts: posts, cases: numOfCases))
                        
                    }
                }
            }
        }
    }
    
    static func fetchUsersWithText(text: String, completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        COLLECTION_USERS.order(by: "firstName").whereField("firstName", isGreaterThanOrEqualTo: text.capitalized).whereField("firstName",
                                                                                                                             isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: 20).getDocuments { snapshot, error in
         
            guard let snapshot = snapshot else {completion(users)
                return
            }
            let fetchedFirstNameUsers = snapshot.documents.map({ User(dictionary: $0.data()) })
            users.append(contentsOf: fetchedFirstNameUsers)
            if fetchedFirstNameUsers.count < 20 {
                let lastNameToFetch = 20 - fetchedFirstNameUsers.count
                
                COLLECTION_USERS.order(by: "lastName").whereField("lastName", isGreaterThanOrEqualTo: text.capitalized).whereField("lastName",
                                                                                                                                   isLessThanOrEqualTo: text.capitalized+"\u{f8ff}").limit(to: lastNameToFetch).getDocuments { snapshot, error in
                    
                    guard let snapshot = snapshot else {
                        completion(users)
                        return
                        
                    }
                    let fetchedLastNameUsers = snapshot.documents.map({ User(dictionary: $0.data()) })
                    users.append(contentsOf: fetchedLastNameUsers)
                    completion(users)
                }
                
            }
        }
    }
}

