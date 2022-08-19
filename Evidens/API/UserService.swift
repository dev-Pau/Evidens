//
//  UserService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import Firebase
import Foundation

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    
    static func updateProfileUrl(profileImageUrl: String, completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["profileImageUrl" : profileImageUrl], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document succesfully written!")
            }
        }
    }
    
    static func updateBannerUrl(bannerImageUrl: String, completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["bannerImageUrl" : bannerImageUrl], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document succesfully written!")
            }
        }
    }
    
    static func updateUserFirstName(firstName: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["firstName": firstName], merge: true) { err in
            
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document succesfully written!")
            }
        }
    }
    
    static func updateUserLastName(lastName: String, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).setData(["lastName": lastName], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document succesfully written!")
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
    
    /*
     static func fetchUsers(withName name: String, completion: @escaping([User]) -> Void) {
     COLLECTION_USERS.whereField("firstName", arrayContains: <#T##Any#>)
     }
     */
    
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
}

